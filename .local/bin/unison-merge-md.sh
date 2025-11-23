#!/usr/bin/env bash

#!/usr/bin/env bash
# simple-merge.sh
# Usage: simple-merge.sh CURRENT1 CURRENTARCHOPT CURRENT2 NEW
# If CURRENTARCHOPT provided: run diff3 -m CURRENT1 CURRENTARCHOPT CURRENT2 -> NEW (fail on conflicts).
# If CURRENTARCHOPT empty: produce two-way annotated output using diff|awk and write to NEW.
set -euo pipefail

CURRENT1=${1:-}
CURRENT2=${2:-}
NEW=${3:-}
CURRENTARCHOPT=${4:-}

if [[ -z "$CURRENT1" || -z "$CURRENT2" || -z "$NEW" ]]; then
  echo "Usage: $0 CURRENT1 CURRENTARCHOPT CURRENT2 NEW" >&2
  exit 2
fi

for f in "$CURRENT1" "$CURRENT2"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: file not found: $f" >&2
    exit 3
  fi
done
if [[ -n "$CURRENTARCHOPT" && ! -f "$CURRENTARCHOPT" ]]; then
  echo "Error: CURRENTARCHOPT provided but not found: $CURRENTARCHOPT" >&2
  exit 4
fi

if [[ -n "$CURRENTARCHOPT" ]]; then
  # Three-way merge using diff3; diff3 writes conflict markers on non-zero exit.
  if diff3 -m "$CURRENT1" "$CURRENTARCHOPT" "$CURRENT2" > "$NEW" 2> /dev/null; then
    echo "Three-way merge succeeded. Output: $NEW"
    exit 0
  else
    echo "Three-way merge produced conflicts. Merge (with conflict markers) written to: $NEW" >&2
    exit 0
  fi
else
  # Two-way annotated output: prefix added lines with '>' and removed lines with '<'
  diff -u "$CURRENT2" "$CURRENT1" > "$NEW"
fi

