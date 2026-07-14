# ~/.config/zsh/zsh.d/40-prompt.zsh — git-aware prompt

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST

# user@host  dir  (git-branch)  %
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f%F{green}${vcs_info_msg_0_}%f %# '
