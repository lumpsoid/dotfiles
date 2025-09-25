#!/usr/bin/env bash
set -euo pipefail

# Usage: ./check_release.sh owner repo [tag]
# Example latest: ./check_release.sh cli cli
# Example specific tag: ./check_release.sh cli cli v1.2.3

OWNER=${1:-}
REPO=${2:-}
TAG=${3:-}  # Optional specific tag (e.g., v1.2.3); if empty, gets the latest

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "Usage: $0 owner repo [tag]"
  exit 2
fi

API="https://api.github.com/repos/${OWNER}/${REPO}/releases"
URL="${API}/latest"
[[ -n "$TAG" ]] && URL="${API}/tags/${TAG}"

echo "Fetching release info from $URL..."
RELEASE_JSON=$(curl -sSL "$URL")

# Error handling
if echo "$RELEASE_JSON" | grep -q '"Not Found"\|"API rate limit exceeded"'; then
  echo "Error: Failed to fetch release. Check owner/repo/tag or API limits."
  echo "$RELEASE_JSON" >&2
  exit 3
fi

# If jq is available, use it for clean output
if command -v jq >/dev/null 2>&1; then
  echo "Release Info:"
  echo "  Tag:         $(echo "$RELEASE_JSON" | jq -r '.tag_name // "N/A"')"
  echo "  Name:        $(echo "$RELEASE_JSON" | jq -r '.name // "N/A"')"
  echo "  Published:   $(echo "$RELEASE_JSON" | jq -r '.published_at // "N/A"')"
  echo "  Assets:"
  echo "$RELEASE_JSON" | jq -r '.assets[]? | "    - " + (.name // "unknown")'
else
  # Fallback if jq is not installed
  TAG_NAME=$(echo "$RELEASE_JSON" | grep -o '"tag_name":[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]+)"/\1/')
  NAME=$(echo "$RELEASE_JSON" | grep -o '"name":[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/.*"([^"]+)"/\1/')
  DATE=$(echo "$RELEASE_JSON" | grep -o '"published_at":[[:space:]]*"[^"]*"' | sed -E 's/.*"([^"]+)"/\1/')

  echo "Release Info:"
  echo "  Tag:         ${TAG_NAME:-N/A}"
  echo "  Name:        ${NAME:-N/A}"
  echo "  Published:   ${DATE:-N/A}"
  echo "  Assets:"
  echo "$RELEASE_JSON" | tr '\n' ' ' | sed -E 's/.*"assets":[[:space:]]*\[([^\]]*)\].*/\1/' | \
    awk -v RS='},' '
      {
        if (match($0, /"name":[[:space:]]*"([^"]+)"/, n)) {
          print "    - " n[1]
        }
      }'
fi

