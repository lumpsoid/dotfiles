# system files
CopyFile /etc/X11/xorg.conf.d/00-keyboard.conf
CopyFile /etc/X11/xorg.conf.d/31-touchpad.conf
#CopyFile /etc/X11/xorg.conf.d/80-igpu-primary-egpu-offload.conf
CopyFile /etc/default/grub
CopyFile /etc/hostname
CopyFile /etc/locale.conf
CreateLink /etc/localtime /usr/share/zoneinfo/Europe/Belgrade
#CopyFile /etc/sudoers
CopyFile /etc/pacman.conf
CopyFile /etc/zsh/zshenv
CopyFile /etc/sysctl.d/dirty.conf
