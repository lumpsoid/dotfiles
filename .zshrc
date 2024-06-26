source /home/qq/.config/zsh/antigen.zsh
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

alias ssh_pi='ssh -i ~/.ssh/pi-qq-home pi@192.168.1.19'

export NNN_OPENER=/home/qq/.config/nnn/plugins/nuke
export GUI=1
n ()
{
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn -C "$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    }
}

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
bindkey -v

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/qq/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

eval "$(navi widget zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/qq/.config/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/qq/.config/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/qq/.config/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/qq/.config/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.local/lib/mojo
export PATH=$PATH:~/.modular/pkg/packages.modular.com_mojo/bin/
