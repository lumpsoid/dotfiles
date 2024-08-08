# path to file, not dir
white_list=(
    'X11/xorg.conf.d/00-keyboard.conf'
    'X11/xorg.conf.d/31-touchpad.conf'
    'X11/xorg.conf.d/80-igpu-primary-egpu-offload.conf'
    'default/grub'
    'hostname'
    'locale.conf'
    'localtime'
    'pacman.conf'
    'zsh/zshenv'
    'modprobe.d/default.conf'
    'modprobe.d/touchpad.conf'
    'modules-load.d/autoload.conf'
    'sysctl.d/dirty.conf'
)
IgnorePathsExcept /etc "${white_list[@]}"
