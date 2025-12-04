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
