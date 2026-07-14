# ~/.config/zsh/.zshrc  → install to: $ZDOTDIR/.zshrc
#
# Loader: sources every *.zsh file in zsh.d/ in alphanumeric order.
# To add config, drop a new NN-name.zsh file in zsh.d/ — no edits needed here.

ZSH_D="${ZDOTDIR:-$HOME/.config/zsh}/zsh.d"
if [[ -d "$ZSH_D" ]]; then
  # (N) = expand to nothing if no matches, instead of erroring
  for _conf in "$ZSH_D"/*.zsh(N); do
    [[ -r "$_conf" ]] && source "$_conf"
  done
  unset _conf
fi
unset ZSH_D
