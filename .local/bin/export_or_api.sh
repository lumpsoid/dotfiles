#!/usr/bin/env bash

FILE_PATH="$HOME/.secrets/openrouter/api"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "File not found: $FILE_PATH"
  return 1
fi

# Read the file and export its content as an environment variable
export OPENROUTER_API_KEY=$(<"$FILE_PATH")

# Print the exported variable (optional, for confirmation)
echo "Environment variable 'OPENROUTER_API_KEY' has been set."
echo "Content of the file: $OPENROUTER_API_KEY"
