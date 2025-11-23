#!/usr/bin/env bash
set -euo pipefail

# Usage: download_github_release.sh [-o OUTPUT] owner repo [asset_pattern] [tag]
# Requires: parse_github_release_json (in PATH or same directory)
# Example: ./download_github_release.sh -o /tmp/cli.tar.gz cli cli "linux_amd64.tar.gz"

OWNER=""
REPO=""
PATTERN=".*"   # regex to match asset name; default matches any asset
TAG=""          # optional specific tag (e.g. v1.2.3); empty = latest
OUT=""          # optional output path
SHOW_HELP=0

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

show_help() {
  cat <<EOF
Usage: $0 [-o OUTPUT] <owner> <repo> [asset_pattern] [tag]

Options:
  -o, --output   Path to write downloaded asset (file or directory).
                 If a directory is given, the asset filename will be used.
                 If not provided, the current directory is used with the asset name.

Arguments:
  owner          GitHub repository owner (e.g. "cli")
  repo           GitHub repository name (e.g. "cli")
  asset_pattern  (Optional) Regex to match asset name. Default: ".*"
  tag            (Optional) Release tag (e.g. "v1.2.3"). Default: latest

Environment:
  GITHUB_TOKEN   (Optional) GitHub token for authenticated API access
                 to avoid rate limiting (recommended)

Note:
  This script expects the helper script 'parse_github_release_json' to be available in PATH
  or in the same directory as this script.
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)
      if [[ -n "${2:-}" ]]; then
        OUT="$2"
        shift 2
        continue
      else
        error "Missing value for $1"
        exit 2
      fi
      ;;
    -h|--help)
      SHOW_HELP=1
      shift
      ;;
    --) shift; break ;;
    -*)
      error "Unknown option: $1"
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [[ $SHOW_HELP -eq 1 ]]; then
  show_help
  exit 0
fi

OWNER=${1:-}
REPO=${2:-}
PATTERN=${3:-$PATTERN}
TAG=${4:-$TAG}

if [[ -z "${OWNER}" || -z "${REPO}" ]]; then
  show_help
  exit 1
fi

# locate parser
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if command -v parse_github_release_json >/dev/null 2>&1; then
  PARSER_CMD="parse_github_release_json.sh"
elif [[ -x "$SCRIPT_DIR/parse_github_release_json.sh" ]]; then
  PARSER_CMD="$SCRIPT_DIR/parse_github_release_json.sh"
else
  error "parse_github_release_json.sh not found in PATH or script directory ($SCRIPT_DIR)."
  exit 2
fi

AUTH_HEADER=""
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
fi

API="https://api.github.com/repos/${OWNER}/${REPO}/releases"
if [[ -n "$TAG" ]]; then
  URL="${API}/tags/${TAG}"
else
  URL="${API}/latest"
fi

# Get release JSON
info "Fetching release info from $URL..."
RELEASE_JSON=$(curl -sSL -H "$AUTH_HEADER" "$URL")

if echo "$RELEASE_JSON" | grep -q '"Not Found"'; then
  warn "Release tag '$TAG' not found for $OWNER/$REPO."
  info "Recent releases:"
  curl -sSL -H "$AUTH_HEADER" "$API" | jq -r '.[].tag_name' | head -n 5
  exit 3
fi

# Basic error check
if echo "$RELEASE_JSON" | grep -q '"Not Found"\|"API rate limit exceeded"'; then
  error "Error fetching release info. Check owner/repo/tag or rate limits."
  echo "$RELEASE_JSON" >&2
  exit 3
fi

# Parse using helper script
info "Parsing release JSON..."
# Feed JSON via stdin to parser to avoid temp files
PARSE_OUTPUT=$(
  printf '%s' "$RELEASE_JSON" | "$PARSER_CMD" - "$PATTERN" 2>/dev/null || true
)

# Ensure parse output present
if [[ -z "$PARSE_OUTPUT" ]]; then
  error "Failed to parse release JSON with $PARSER_CMD"
  exit 3
fi

# Read key=value lines
eval "$(printf '%s\n' "$PARSE_OUTPUT" | sed -n 's/^TAG_NAME=/TAG_NAME=/p; s/^ASSET_NAME=/ASSET_NAME=/p; s/^ASSET_URL=/ASSET_URL=/p')"

# sanitize empty/null
TAG_NAME=${TAG_NAME:-}
ASSET_NAME=${ASSET_NAME:-}
ASSET_URL=${ASSET_URL:-}

if [[ -z "$ASSET_URL" ]]; then
  warn "No asset found matching pattern '$PATTERN' in release '$TAG_NAME'."
  info "Available assets:"
  if command -v jq >/dev/null 2>&1; then
    echo "$RELEASE_JSON" | jq -r '.assets[]?.name'
  else
    # fallback crude listing
    echo "$RELEASE_JSON" | tr '\n' ' ' | sed -E 's/.*"assets":[[:space:]]*$$([^]]*)$$.*/\1/' | \
      awk -v RS='},' '{ if (match($0, /"name":[[:space:]]*"([^"]+)"/, n)) print n[1] }'
  fi
  exit 4
fi

# Determine output file path
OUTPATH="$OUT"
if [[ -z "$OUTPATH" ]]; then
  OUTPATH="${ASSET_NAME##*/}"
else
  # If OUTPATH is a directory, append filename
  if [[ -d "$OUTPATH" ]]; then
    OUTPATH="${OUTPATH%/}/${ASSET_NAME##*/}"
  else
    # If ends with / treat as dir (even if non-existent)
    if [[ "${OUTPATH: -1}" == "/" ]]; then
      mkdir -p "$OUTPATH"
      OUTPATH="${OUTPATH%/}/${ASSET_NAME##*/}"
    fi
  fi
fi

info "Downloading asset '$ASSET_NAME' from release '$TAG_NAME' to '$OUTPATH'..."
curl -L -o "$OUTPATH" "$ASSET_URL"

info "Successfully downloaded: $OUTPATH"

