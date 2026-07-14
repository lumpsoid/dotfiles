# ~/.config/zsh/zsh.d/30-keybindings.zsh — key bindings

bindkey -e                                # emacs-style bindings (swap for -v to get vi mode)
bindkey '^[[A' history-beginning-search-backward  # Up: search history by prefix
bindkey '^[[B' history-beginning-search-forward   # Down: same, forward
bindkey '^[[H' beginning-of-line          # Home
bindkey '^[[F' end-of-line                # End
bindkey '^[[3~' delete-char               # Delete
