#!/usr/bin/env bash
# =============================================================================
# arch-recover.sh
#
# WHY THIS SCRIPT EXISTS:
#   A healthy Arch system requires that every `pacman -Syu` was fully completed.
#   If you ever:
#     - interrupted an upgrade mid-way
#     - skipped a sync for weeks/months
#     - had mirror failures (503/404) silently abort updates
#     - installed packages from AUR while base packages lagged behind
#     - rebooted into a kernel that didn't match installed modules
#
#   ...then your system may be in a "partial upgrade" state. This is one of the
#   most dangerous states on a rolling release distro. Symptoms include:
#     - random segfaults or missing .so libraries
#     - programs that launch but crash immediately
#     - AUR packages that refuse to build
#     - pacman itself misbehaving
#
#   This script does a full diagnosis first, then fixes what it finds.
#   It is intentionally verbose so you understand what is happening.
#
# USAGE:
#   chmod +x arch-recover.sh
#   sudo ./arch-recover.sh
#
# SAFE TO RE-RUN: yes. Every step is idempotent.
# =============================================================================

set -euo pipefail

# ---- Colors for readability -------------------------------------------------
RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLU}[INFO]${NC}  $*"; }
warn()  { echo -e "${YEL}[WARN]${NC}  $*"; }
ok()    { echo -e "${GRN}[ OK ]${NC}  $*"; }
error() { echo -e "${RED}[ERR ]${NC}  $*"; }
hr()    { echo -e "${BLU}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ---- Root check -------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    error "Must be run as root. Use: sudo $0"
    exit 1
fi

hr
info "Arch Linux system diagnosis and recovery"
info "Started: $(date)"
hr

# =============================================================================
# STEP 1 — Check for interrupted/locked pacman transactions
# =============================================================================
# If a previous pacman run was killed (power loss, Ctrl+C, OOM), it leaves a
# lockfile behind. Every future pacman call will refuse to run until it's gone.
# Removing it is safe ONLY when no pacman process is actually running.
hr
info "STEP 1: Checking for stale pacman lock..."

LOCK="/var/lib/pacman/db.lck"
if [[ -f "$LOCK" ]]; then
    if pgrep -x pacman &>/dev/null; then
        error "pacman is currently running! Do not remove the lock."
        error "Wait for it to finish or find and kill the process."
        exit 1
    else
        warn "Stale lock found (no pacman process running). Removing..."
        rm -f "$LOCK"
        ok "Lock removed."
    fi
else
    ok "No stale lock."
fi

# =============================================================================
# STEP 2 — Refresh mirrors (same logic as refresh-mirrors.sh)
# =============================================================================
# We do this BEFORE touching any packages because if mirrors are broken,
# every subsequent pacman operation will fail anyway.
hr
info "STEP 2: Refreshing mirrorlist..."

if ! command -v reflector &>/dev/null; then
    warn "reflector not found. Installing..."
    # We use --needed so it's a no-op if somehow already installed mid-failure
    pacman -S --noconfirm --needed reflector
fi

MIRRORLIST="/etc/pacman.d/mirrorlist"
cp "$MIRRORLIST" "${MIRRORLIST}.bak"
info "Old mirrorlist backed up to ${MIRRORLIST}.bak"

reflector \
    --protocol https \
    --age 12 \
    --sort rate \
    --number 10 \
    --save "$MIRRORLIST"

ok "Mirrorlist updated. Top mirror: $(grep '^Server' "$MIRRORLIST" | head -1)"

# =============================================================================
# STEP 3 — Force-refresh ALL package databases
# =============================================================================
# `-Syy` (double y) forces a re-download of every repo database even if pacman
# thinks it already has a fresh copy. This matters because:
#   - your cached .db files might be from a now-dead mirror
#   - after a mirror switch, the version numbers in the db must match the files
#     actually available on the new mirror
hr
info "STEP 3: Force-refreshing package databases (pacman -Syy)..."
pacman -Syy
ok "Package databases refreshed."

# =============================================================================
# STEP 4 — Detect partial upgrades
# =============================================================================
# A partial upgrade means some packages were updated and others weren't.
# pacman can tell us: packages where the locally installed version is OLDER
# than what the db now says is current.
hr
info "STEP 4: Checking for pending upgrades (partial upgrade detection)..."

PENDING=$(pacman -Qu 2>/dev/null | wc -l)
if [[ "$PENDING" -gt 0 ]]; then
    warn "$PENDING package(s) are out of date:"
    pacman -Qu
    echo ""
    warn "This confirms a partial upgrade state. Step 6 will fix this."
else
    ok "All installed packages match current repo versions."
fi

# =============================================================================
# STEP 5 — Check for missing/broken shared libraries
# =============================================================================
# When a library package updates but a dependent package was NOT updated
# alongside it, the dependent binary will reference a .so version that no
# longer exists on disk. This causes the "error while loading shared libraries"
# crash at runtime — the hardest class of partial-upgrade breakage to debug.
hr
info "STEP 5: Scanning for broken shared library links..."

if command -v ldconfig &>/dev/null; then
    # ldconfig -p lists every cached library. We cross-check against what's
    # actually on disk. Missing files = broken links.
    BROKEN=$(ldconfig -p | awk '{print $NF}' | xargs -I{} sh -c '[ -f "{}" ] || echo "MISSING: {}"' 2>/dev/null || true)
    if [[ -n "$BROKEN" ]]; then
        warn "Broken library links found:"
        echo "$BROKEN"
    else
        ok "No broken library links detected."
    fi
fi

# paccheck (from pacutils) gives a deeper check: it verifies every file
# owned by pacman actually exists and hasn't been corrupted.
if command -v paccheck &>/dev/null; then
    info "Running paccheck for missing/corrupted package files..."
    paccheck --quiet --db-files --files 2>&1 | grep -v "^$" || true
else
    warn "paccheck not available (install pacutils for deeper file checks)."
    warn "  sudo pacman -S pacutils"
fi

# =============================================================================
# STEP 6 — Full system upgrade
# =============================================================================
# Now that mirrors are fresh and dbs are synced, do the full upgrade.
# We use `-Syu` (not just `-Su`) so pacman re-confirms db freshness.
# --needed skips reinstalling already-current packages (faster).
hr
info "STEP 6: Running full system upgrade..."
pacman -Syu --needed

ok "System upgrade complete."

# =============================================================================
# STEP 7 — Rebuild the shared library cache
# =============================================================================
# After any upgrade that touched libraries, ldconfig must re-scan /usr/lib
# to rebuild its cache. Without this, newly installed .so files won't be
# found by the dynamic linker until next boot (or until ldconfig runs).
hr
info "STEP 7: Rebuilding shared library cache (ldconfig)..."
ldconfig
ok "ldconfig complete."

# =============================================================================
# STEP 8 — Check if a reboot is needed
# =============================================================================
# The running kernel is loaded in RAM. If the kernel package just upgraded,
# the running version and the on-disk version are now different. Kernel modules
# (drivers) for the NEW kernel won't load until you reboot. This is the #1
# cause of "module not found" errors after an upgrade.
hr
info "STEP 8: Checking if a reboot is required..."

RUNNING_KERNEL=$(uname -r)
# The newest installed kernel image on disk:
INSTALLED_KERNEL=$(ls /usr/lib/modules/ | sort -V | tail -1)

if [[ "$RUNNING_KERNEL" != "$INSTALLED_KERNEL" ]]; then
    warn "Kernel mismatch detected!"
    warn "  Running : $RUNNING_KERNEL"
    warn "  On disk : $INSTALLED_KERNEL"
    warn "  >>> REBOOT REQUIRED <<<"
    warn "  Until you reboot, kernel modules for the new kernel won't load."
else
    ok "Running kernel matches installed kernel ($RUNNING_KERNEL). No reboot needed."
fi

# =============================================================================
# STEP 9 — Check for .pacnew config files that need merging
# =============================================================================
# When pacman upgrades a package whose config file you have modified, it can't
# overwrite your version. Instead it drops a .pacnew file next to yours.
# Ignoring these can mean missing important config changes from upstream.
hr
info "STEP 9: Scanning for unmerged .pacnew config files..."

PACNEW=$(find /etc -name "*.pacnew" 2>/dev/null)
if [[ -n "$PACNEW" ]]; then
    warn "Unmerged .pacnew files found (review and merge these manually):"
    echo "$PACNEW"
    warn "Use 'pacdiff' or 'meld' to diff and merge them."
    warn "  sudo pacdiff   (install pacman-contrib if missing)"
else
    ok "No .pacnew files found."
fi

# =============================================================================
# DONE
# =============================================================================
hr
ok "All steps complete. Summary:"
echo ""
echo "  Mirrorlist  → refreshed, backed up to ${MIRRORLIST}.bak"
echo "  Pacman lock → cleared if stale"
echo "  Databases   → force-refreshed from new mirrors"
echo "  Packages    → fully upgraded"
echo "  ldconfig    → rebuilt"
echo ""

if [[ "$RUNNING_KERNEL" != "$INSTALLED_KERNEL" ]]; then
    echo -e "  ${RED}ACTION REQUIRED: reboot to load new kernel ($INSTALLED_KERNEL)${NC}"
fi
if [[ -n "${PACNEW:-}" ]]; then
    echo -e "  ${YEL}ACTION REQUIRED: merge .pacnew config files (see above)${NC}"
fi

hr
info "Finished: $(date)"
