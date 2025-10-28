#!/usr/bin/env bash
# parse_github_release_json.sh
# Usage: parse_github_release_json <json-file-or-stdin> <asset_pattern>
# Outputs three lines to stdout:
#   TAG_NAME=<tag_or_name>
#   ASSET_NAME=<asset name or empty>
#   ASSET_URL=<browser_download_url or empty>
# Exit codes:
#   0 = success (asset may be empty)
#   2 = invalid args / file not readable
#   3 = parsing error

set -euo pipefail

PATTERN="${2:-.*}"
INPUT="${1:-}"

error() { printf '[ERROR] %s\n' "$*" >&2; }

if [[ -n "$INPUT" && "$INPUT" != "-" ]]; then
  if [[ ! -r "$INPUT" ]]; then
    error "Cannot read input file: $INPUT"
    exit 2
  fi
  JSON="$(cat "$INPUT")"
else
  JSON="$(cat -)"
fi

# normalize empty pattern
if [[ -z "$PATTERN" ]]; then PATTERN=".*"; fi

TAG_NAME=""
ASSET_NAME=""
ASSET_URL=""

# Prefer jq if available
if command -v jq >/dev/null 2>&1; then
  TAG_NAME=$(printf '%s' "$JSON" | jq -r '.tag_name // .name // empty')
  ASSET_NAME=$(printf '%s' "$JSON" | jq -r --arg pat "$PATTERN" '.assets[]? | select(.name | test($pat)) | .name' | head -n1 || true)
  ASSET_URL=$(printf '%s' "$JSON" | jq -r --arg pat "$PATTERN" '.assets[]? | select(.name | test($pat)) | .browser_download_url' | head -n1 || true)
else
  # Fallback parsing (crude but works for typical GitHub release JSON)
  TAG_NAME=$(printf '%s' "$JSON" | sed -n 's/.*"tag_name":[[:space:]]*"$[^"]*$".*/\1/p; t; s/.*"name":[[:space:]]*"$[^"]*$".*/\1/p' | head -n1 || true)
  # Extract assets array body
  ASSETS_BODY=$(printf '%s' "$JSON" | tr '\n' ' ' | sed -E 's/.*"assets":[[:space:]]*$$([^]]*)$$.*/\1/' || true)
  if [[ -n "$ASSETS_BODY" ]]; then
    # split by "}," records
    awk -v body="$ASSETS_BODY" -v pat="$PATTERN" 'BEGIN{
      RS="},"
      n=split(body, a, /},/)
      for(i=1;i<=n;i++){
        s=a[i]
        name=""
        url=""
        if (match(s, /"name":[[:space:]]*"([^"]+)"/, m)) name=m[1]
        if (match(s, /"browser_download_url":[[:space:]]*"([^"]+)"/, u)) url=u[1]
        if (name != "" && url != ""){
          if (pat == ".*" || name ~ pat){
            print name "||" url
            exit 0
          }
        }
      }
    }' || true > /tmp/parse_github_assets.$ 2>/dev/null || true
    if [[ -s /tmp/parse_github_assets.$ ]]; then
      IFS='||' read -r ASSET_NAME ASSET_URL < /tmp/parse_github_assets.$
      rm -f /tmp/parse_github_assets.$
    else
      rm -f /tmp/parse_github_assets.$ 2>/dev/null || true
    fi
  fi
fi

# sanitize "null" to empty
if [[ "${TAG_NAME:-}" == "null" ]]; then TAG_NAME=""; fi
if [[ "${ASSET_NAME:-}" == "null" ]]; then ASSET_NAME=""; fi
if [[ "${ASSET_URL:-}" == "null" ]]; then ASSET_URL=""; fi

# Final sanity: ensure variables contain no newlines
TAG_NAME=$(printf '%s' "$TAG_NAME" | tr -d '\r\n')
ASSET_NAME=$(printf '%s' "$ASSET_NAME" | tr -d '\r\n')
ASSET_URL=$(printf '%s' "$ASSET_URL" | tr -d '\r\n')

# Output key=value lines
printf 'TAG_NAME=%s\n' "$TAG_NAME"
printf 'ASSET_NAME=%s\n' "$ASSET_NAME"
printf 'ASSET_URL=%s\n' "$ASSET_URL"

exit 0

