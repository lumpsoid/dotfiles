# ~/.config/zsh/zsh.d/20-completion.zsh — completion system

# Keep the compdump cache out of the config dir.
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"

autoload -Uz compinit && compinit -d "$_zcompdump"
unset _zcompdump

zstyle ':completion:*' menu select                        # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # colored listing
zstyle ':completion:*' group-name ''                      # group matches by type
