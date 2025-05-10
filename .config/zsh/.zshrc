source "$ZDOTDIR/antigen.zsh"
antigen use oh-my-zsh
antigen theme pmcgee
antigen bundle sudo
antigen bundle git
antigen bundle "MichaelAquilina/zsh-you-should-use"
#antigen bundle "skywind3000/z.lua"
antigen bundle "zsh-users/zsh-syntax-highlighting"
antigen apply

export PATH="$PATH":"$HOME/.local/bin"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH":"$HOME/.cargo/bin"
export PATH="$PATH":"/home/qq/Documents/programming/flutter/flutter/bin"

# android development
export ANDROID_HOME=/home/qq/.config/Android
export ANDROID_AVD_HOME=/home/qq/.config/.android/avd/
export PATH="$PATH":"$ANDROID_HOME/tools"
export PATH="$PATH":"$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH":"$ANDROID_HOME/platform-tools"
#export ANDROID_SDK_ROOT=/home/qq/.config/.android

#flutter web dev
export CHROME_EXECUTABLE=/usr/bin/chromium

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="yyyy-mm-dd"
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

eval "$(navi widget zsh)"
