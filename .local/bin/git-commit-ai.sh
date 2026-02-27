#!/usr/bin/env bash
#
# git-commit-ai.sh - Generate conventional commit messages from git diffs using AI
#
# Usage: ./git-commit-ai.sh <model> <commit-ish>
# Example: ./git-commit-ai.sh 'stepfun/step-3.5-flash:free' HEAD~1

set -euo pipefail

# Configuration
OPENROUTER_CLI="${OPENROUTER_CLI:-$HOME/.local/bin/openrouter-cli.sh}"
PROMPT="Write a conventional commit message for the diff below. Follow the Conventional Commits specification (https://www.conventionalcommits.org/). Use the format: <type>(<scope>): <description>. Types: feat, fix, docs, style, refactor, perf, test, chore, build, ci. Keep it concise (max 50 chars for subject, 72 for body)."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Validate inputs
if [ $# -ne 2 ]; then
    echo -e "${RED}Error:${NC} Two arguments required: <model> <commit-ish>"
    echo "Usage: $0 <model> <commit-ish>"
    echo "Example: $0 'stepfun/step-3.5-flash:free' HEAD~1"
    exit 1
fi

MODEL="$1"
COMMIT="$2"

# Check dependencies
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error:${NC} git is not installed" >&2
    exit 1
fi

if [ ! -x "$OPENROUTER_CLI" ]; then
    echo -e "${RED}Error:${NC} OpenRouter CLI not found at: $OPENROUTER_CLI" >&2
    echo "Set OPENROUTER_CLI environment variable to override path." >&2
    exit 1
fi

# Validate commit reference
if ! git rev-parse --verify "$COMMIT" &>/dev/null; then
    echo -e "${RED}Error:${NC} Invalid commit reference: $COMMIT" >&2
    exit 1
fi

# Get the diff
echo "🔍 Getting diff for commit: $COMMIT"
DIFF=$(git show "$COMMIT" --pretty=format: --no-color 2>/dev/null)

if [ -z "$DIFF" ]; then
    echo -e "${RED}Error:${NC} Commit $COMMIT has no changes (empty diff)" >&2
    exit 1
fi

# Create temporary file for diff
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "$DIFF" > "$TMPFILE"

# Generate commit message
echo "🤖 Generating commit message using model: $MODEL"
echo ""

if COMMIT_MSG=$("$OPENROUTER_CLI" \
    -m "$MODEL" \
    -a "$PROMPT" \
    -f "$TMPFILE" 2>/dev/null); then
    
    echo -e "${GREEN}✓ Generated commit message:${NC}"
    echo "---"
    echo "$COMMIT_MSG"
    echo "---"
else
    echo -e "${RED}✗ Failed to generate commit message${NC}" >&2
    echo "Try checking your OpenRouter API key or model availability." >&2
    exit 1
fi
