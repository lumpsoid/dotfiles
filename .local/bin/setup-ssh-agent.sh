#!/usr/bin/env bash

# ==============================================================================
# SSH Agent Persistence Script
#
# This script checks for an existing ssh-agent, starts one if needed,
# and ensures the current shell is connected to it.
# It is designed to be sourced from your .bashrc or .zshrc file.
# ==============================================================================

# File to store the agent environment variables.
AGENT_ENV_FILE="$HOME/.ssh/agent-env"
# Optional: A log file for debugging. Comment out to disable logging.
LOG_FILE="$HOME/.ssh/agent.log"

log() {
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

# 1. Check if we are already connected to a running agent.
# The '-S' test checks if the path exists and is a socket.
if [[ -S "$SSH_AUTH_SOCK" ]]; then
    log "Found existing SSH_AUTH_SOCK. Agent is already running."
    # Optional: You can add a check here to see if your key is already loaded.
    # ssh-add -l &>/dev/null || log "Agent is running, but no keys are loaded."
else
    log "No SSH_AUTH_SOCK found. Attempting to connect to an agent."

    # 2. If not connected, try to source the environment from our file.
    if [[ -f "$AGENT_ENV_FILE" ]]; then
        log "Found agent environment file at '$AGENT_ENV_FILE'. Sourcing it."
        # shellcheck source=/dev/null
        source "$AGENT_ENV_FILE" >/dev/null

        # 3. After sourcing, verify the agent is actually alive by checking its PID.
        # 'kill -0' checks if a process exists without sending a signal.
        if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            log "Agent PID $SSH_AGENT_PID from file is not running. Removing stale file."
            rm -f "$AGENT_ENV_FILE"
        fi
    fi

    # 4. If we still don't have a connection (either no file or stale PID), start a new agent.
    if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
        log "No running agent found. Starting a new one."
        ssh-agent -s > "$AGENT_ENV_FILE"
        # shellcheck source=/dev/null
        source "$AGENT_ENV_FILE" >/dev/null
        log "Started new agent with PID $SSH_AGENT_PID."
    fi
fi
