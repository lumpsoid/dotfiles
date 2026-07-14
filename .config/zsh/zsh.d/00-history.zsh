# ~/.config/zsh/zsh.d/00-history.zsh — history

# History is state, not config, so keep it out of the (git-tracked) config dir.
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000           # lines kept in memory
SAVEHIST=50000           # lines written to disk

# Make sure the directory exists (${HISTFILE:h} = the directory part)
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

setopt APPEND_HISTORY        # append rather than overwrite
setopt INC_APPEND_HISTORY    # write commands as they're entered
setopt SHARE_HISTORY         # share history across open sessions
setopt HIST_IGNORE_DUPS      # don't record a duplicate of the last command
setopt HIST_IGNORE_ALL_DUPS  # remove older duplicate entries
setopt HIST_IGNORE_SPACE     # ignore commands that start with a space
setopt HIST_REDUCE_BLANKS    # strip superfluous whitespace
setopt HIST_VERIFY           # show !! expansion before running it
