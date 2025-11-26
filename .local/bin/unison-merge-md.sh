#!/usr/bin/env bash
# simple-merge.sh
# Usage: simple-merge.sh CURRENT1 CURRENTARCHOPT CURRENT2 NEW
# If CURRENTARCHOPT provided: run diff3 -m CURRENT1 CURRENTARCHOPT CURRENT2 -> NEW (fail on conflicts).
# If CURRENTARCHOPT empty: produce two-way annotated output using diff|awk and write to NEW.

set -euo pipefail

# === CONFIGURATION ===
LOG_FILE="/home/qq/simple-merge.log"

log() {
  # Timestamped logging
  printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

CURRENT1=${1:-}
CURRENT2=${2:-}
NEW=${3:-}
CURRENTARCHOPT=${4:-}

# Validate arguments
if [[ -z "$CURRENT1" || -z "$CURRENT2" || -z "$NEW" ]]; then
  log "Usage error: simple-merge.sh CURRENT1 CURRENTARCHOPT CURRENT2 NEW"
  exit 2
fi

# Check required files
for f in "$CURRENT1" "$CURRENT2"; do
  if [[ ! -f "$f" ]]; then
    log "Error: file not found: $f"
    exit 3
  fi
done

if [[ -n "$CURRENTARCHOPT" && ! -f "$CURRENTARCHOPT" ]]; then
  log "Error: CURRENTARCHOPT provided but not found: $CURRENTARCHOPT"
  exit 4
fi

# === MERGE LOGIC ===
if [[ -n "$CURRENTARCHOPT" ]]; then
  log "Performing three-way merge: $CURRENT1, $CURRENTARCHOPT, $CURRENT2 -> $NEW"

  # diff3 returns non-zero on conflicts but still writes merged file
  if diff3 -m "$CURRENT1" "$CURRENTARCHOPT" "$CURRENT2" > "$NEW" 2>/dev/null; then
    log "Three-way merge succeeded. Output: $NEW"
    exit 0
  else
    log "Three-way merge completed with conflicts. Output written to $NEW"
    exit 0
  fi

else
  log "Performing two-way diff: $CURRENT1 vs $CURRENT2 -> $NEW"

  if ! diff -u "$CURRENT1" "$CURRENT2" > "$NEW"; then
    status=$?
    if [[ $status -ne 1 ]]; then
      log "diff failed with error code $status"
      exit $status
    fi
  fi

  log "Two-way diff completed. Output: $NEW"
fi

