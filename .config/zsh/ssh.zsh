# Load ssh-agent environment
if [ -f ~/.ssh/agent-env ]; then
    source ~/.ssh/agent-env > /dev/null
    # Check if the agent is still running
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        # Agent is dead, remove the file
        rm ~/.ssh/agent-env
    fi
fi
