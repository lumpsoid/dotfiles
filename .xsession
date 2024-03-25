#!/bin/sh

#mailsync &
#remind -z -k'gxmessage -title "reminder" %s &' ~/.config/remind/uni.rem & 
#lxpolkit &
#picom &
#autokey-gtk &
eval "$(/usr/bin/ssh-agent -s)"
/usr/bin/pipewire &
/usr/bin/pipewire-pulse &
/usr/bin/wireplumber &
/usr/bin/dunst &
/usr/local/bin/dwmblocks &
exec /usr/local/bin/dwm

