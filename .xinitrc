#!/usr/bin/env sh
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
# merge in defaults and keymaps
if [ -f $sysresources ]; then
	xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
	xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
	xrdb -merge "$userresources"
fi
if [ -f "$usermodmap" ]; then
	xmodmap "$usermodmap"
fi
# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
	for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
	[ -x "$f" ] && . "$f"
	done
	unset f
fi

#xset r rate 300 50

export XDG_SESSION_TYPE=x11

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ssh_git

dunst &

exec awesome
