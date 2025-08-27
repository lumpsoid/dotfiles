source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='%F{green}%T%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="yyyy-mm-dd"
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

eval "$(navi widget zsh)"

# Load ssh-agent environment
if [ -f ~/.ssh/agent-env ]; then
    source ~/.ssh/agent-env > /dev/null
    # Check if the agent is still running
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        # Agent is dead, remove the file
        rm ~/.ssh/agent-env
    fi
fi

# Keybindings
# Enable key bindings
bindkey -e  # Use emacs-style key bindings (default)

# Word deletion and navigation
bindkey '^H' backward-kill-word        # Ctrl+Backspace - delete word backward
bindkey '^[[3;5~' kill-word           # Ctrl+Delete - delete word forward
bindkey '^A' beginning-of-line        # Ctrl+A - go to beginning of line
bindkey '^E' end-of-line              # Ctrl+E - go to end of line

# Home/End keys (may vary by terminal)
bindkey '^[[H' beginning-of-line      # Home
bindkey '^[[F' end-of-line            # End
bindkey '^[[1~' beginning-of-line     # Alternative Home
bindkey '^[[4~' end-of-line           # Alternative End

# Arrow key word movement
bindkey '^[[1;5C' forward-word        # Ctrl+Right Arrow
bindkey '^[[1;5D' backward-word       # Ctrl+Left Arrow

# Line editing
bindkey '^K' kill-line                # Ctrl+K - delete from cursor to end
bindkey '^U' backward-kill-line       # Ctrl+U - delete from cursor to beginning
