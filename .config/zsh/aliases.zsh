alias bb="exit"

alias ld='ls -d */'  # List only directories
alias l='ls -lah'    # Detailed list view

# Enhanced commands
alias cp='cp -iv'    # Confirm before overwrite, verbose
alias mv='mv -iv'    # Confirm before overwrite, verbose
alias rm='rm -i'     # Interactive removal
alias df='df -h'     # Human-readable disk space
alias free='free -h' # Human-readable memory

# flutter/dart
alias danalyze='dart analyze .'
alias dformat='dart format .'

# Disk Usage Variants
alias duh='du -h'                   # Human-readable disk usage
alias dud='du -hd 1'                # Disk usage, depth 1
alias duds='du -hd 1 | sort -h'      # Disk usage, depth 1, sorted
alias dud2='du -hd 2'               # Disk usage, depth 2
alias dud2s='du -hd 2 | sort -h'     # Sorted disk usage

