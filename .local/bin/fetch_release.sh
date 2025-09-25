#!/usr/bin/env bash
set -euo pipefail

# Usage: download_github_release.sh owner repo [asset_pattern] [tag]
# Example: ./download_github_release.sh cli cli "linux_amd64.tar.gz"
# Example latest: ./download_github_release.sh owner repo ".*linux.*"
# Example specific tag: ./download_github_release.sh owner repo ".*" v1.2.3

OWNER=${1:-}
REPO=${2:-}
PATTERN=${3:-.*}   # regex to match asset name; default matches any asset
TAG=${4:-}         # optional specific tag (e.g. v1.2.3); empty = latest

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()    { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

show_help() {
  cat <<EOF
Usage: $0 <owner> <repo> [asset_pattern] [tag]

Arguments:
  owner          GitHub repository owner (e.g. "cli")
  repo           GitHub repository name (e.g. "cli")
  asset_pattern  (Optional) Regex to match asset name. Default: ".*"
  tag            (Optional) Release tag (e.g. "v1.2.3"). Default: latest

Examples:
  $0 cli cli
  $0 cli cli "linux_amd64.tar.gz"
  $0 cli cli ".*linux.*"
  $0 cli cli ".*" v1.2.3

Environment:
  GITHUB_TOKEN   (Optional) GitHub token for authenticated API access
                 to avoid rate limiting (recommended)

EOF
}

if [[ "${1:-}" == "--help" || -z "${OWNER}" || -z "${REPO}" ]]; then
  show_help
  exit 1
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

# Extract tag_name and list assets (use jq if available; fallback to grep/sed)
if command -v jq >/dev/null 2>&1; then
  TAG_NAME=$(echo "$RELEASE_JSON" | jq -r '.tag_name // .name')
  # Find first asset matching PATTERN
  ASSET_URL=$(echo "$RELEASE_JSON" | jq -r --arg pat "$PATTERN" '.assets[] | select(.name | test($pat)) | .browser_download_url' | head -n1)
  ASSET_NAME=$(echo "$RELEASE_JSON" | jq -r --arg pat "$PATTERN" '.assets[] | select(.name | test($pat)) | .name' | head -n1)
else
  TAG_NAME=$(echo "$RELEASE_JSON" | sed -n 's/.*"tag_name":[[:space:]]*"$[^"]*$".*/\1/p; t; s/.*"name":[[:space:]]*"$[^"]*$".*/\1/p' | head -n1)
  # crude asset extraction
  # produce lines "name||browser_download_url"
  ASSET_LINE=$(echo "$RELEASE_JSON" | tr '\n' ' ' | sed -E 's/.*"assets":[[:space:]]*$$([^]]*)$$.*/\1/' | \
    awk -v RS='},' '
      {
        if (match($0, /"name":[[:space:]]*"([^"]+)"/, n) && match($0, /"browser_download_url":[[:space:]]*"([^"]+)"/, u)) {
          print n[1] "||" u[1]
        }
      }' | grep -E "$PATTERN" | head -n1 || true)
  ASSET_NAME=${ASSET_LINE%%||*}
  ASSET_URL=${ASSET_LINE#*||}
  if [[ "$ASSET_URL" == "$ASSET_NAME" ]]; then ASSET_URL=""; fi
fi

if [[ -z "$ASSET_URL" || "$ASSET_URL" == "null" ]]; then
  warn "No asset found matching pattern '$PATTERN' in release '$TAG_NAME'."
  info "Available assets:"
  if command -v jq >/dev/null 2>&1; then
    echo "$RELEASE_JSON" | jq -r '.assets[]?.name'
  else
    echo "$RELEASE_JSON" | tr '\n' ' ' | sed -E 's/.*"assets":[[:space:]]*$$([^]]*)$$.*/\1/' | \
      awk -v RS='},' '{ if (match($0, /"name":[[:space:]]*"([^"]+)"/, n)) print n[1] }'
  fi
  exit 4
fi

OUT="${ASSET_NAME##*/}"
info "Downloading asset '$ASSET_NAME' from release '$TAG_NAME'..."
# Use curl to follow redirects and show progress; save with final filename
curl -L -o "$OUT" "$ASSET_URL"

info "Successfully downloaded: $OUT"

