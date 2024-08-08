yambar &
pipewire &
pipewire-pulse &
wireplumber &
lxqt-policykit-agent &
dunst &
gnome-keyring-daemon &

dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ssh_git

tee ~/.cache/dwl_info 2> /tmp/dwl-console.log
exec <&-
