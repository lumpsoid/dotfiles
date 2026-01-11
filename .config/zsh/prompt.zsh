# --- Git support via vcs_info ---
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' formats '%b '

precmd() {
  vcs_info
}

# --- Jujutsu prompt ---
jj_prompt() {
  # Fast check: are we inside a JJ repo?
  jj root &>/dev/null || return

  # Show bookmark(s) if present, otherwise short change id
  jj log -r @ --no-graph --template 'change_id.short()' 2>/dev/null
}

# --- Unified VCS prompt: JJ > Git ---
vcs_prompt() {
  local jj
  jj=$(jj_prompt)

  if [[ -n $jj ]]; then
    print -r -- "$jj "
  else
    print -r -- "$vcs_info_msg_0_"
  fi
}

# --- Final prompt ---
setopt PROMPT_SUBST

PROMPT='%F{green}%T%f %F{blue}%~%f %F{red}$(vcs_prompt)%f$ '
