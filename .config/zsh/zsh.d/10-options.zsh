# ~/.config/zsh/zsh.d/10-options.zsh — navigation & shell behavior

setopt AUTO_CD               # type a dir name to cd into it
setopt AUTO_PUSHD            # cd pushes onto the directory stack
setopt PUSHD_IGNORE_DUPS     # no duplicate dirs on the stack
setopt CORRECT               # offer to correct mistyped commands
setopt INTERACTIVE_COMMENTS  # allow # comments in the interactive shell
setopt NO_BEEP               # silence the terminal bell
