# ~/.config/zsh/zsh.d/90-plugins.zsh — third-party plugins
#
# This file is numbered 90 so it loads LAST. Order within it matters too:
# autosuggestions first, syntax-highlighting absolutely last (it wraps the
# line editor; anything sourced after it won't be highlighted).
#
# Install the packages with:
#   sudo dnf install zsh-autosuggestions zsh-syntax-highlighting

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

source /home/qq/Projects/personal/worktree-random/worktree.sh
