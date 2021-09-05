#!/bin/sh

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
dbus-launch --sh-syntax --exit-with-session

sleep 1
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

export PATH=$HOME/scripts:$PATH

# apply wallpaper after screen set
. ~/mxctl/env
mxctl.control fun setup_video
~/scripts/xdg/x.wallpaper.sh cycle &

bgfpid mxctl.control "cmd autolockd_xautolock"
[ -f /usr/bin/compton ] && (compton &)
[ -f /usr/bin/picom   ] && (picom &)

sleep 1
dunst &
clipit &
nm-applet --sm-disable &
setxkbmap us &
xsetroot -cursor_name left_ptr &

sleep 1
bgfpid mpd
bgfpid ~/local/bin/ympd "--webport 8080"
VBoxClient --clipboard &
