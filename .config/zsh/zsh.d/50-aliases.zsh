# ~/.config/zsh/zsh.d/50-aliases.zsh — aliases
alias bb="exit"

alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias ..='cd ..'
alias ...='cd ../..'

# Enhanced commands
alias cp='cp -iv'    # Confirm before overwrite, verbose
alias mv='mv -iv'    # Confirm before overwrite, verbose
alias rm='rm -i'     # Interactive removal
alias df='df -h'     # Human-readable disk space
alias free='free -h' # Human-readable memory

# Disk Usage Variants
alias duh='du -h'                   # Human-readable disk usage
alias dud='du -hd 1'                # Disk usage, depth 1
alias dud2='du -hd 2'               # Disk usage, depth 2
alias dud2s='du -hd 2 | sort -h'     # Sorted disk usage

