#!/bin/sh

bgfpid=~/scripts/bgfpid

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
dbus-launch --sh-syntax --exit-with-session
sleep 1
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# monitoring
. ~/frmad/env
$bgfpid ~/.luarocks/bin/frmad.cached "- - 2>&1 > /tmp/frmad.cached.log"
sleep 1
$bgfpid ~/.luarocks/bin/frmad.daemon "2>&1 > /tmp/frmad.daemon.log"

#screen
. ~/mxctl/env
~/.luarocks/bin/mxctl.control fun setup_video
[ -f /usr/bin/compton ] && (compton &)
[ -f /usr/bin/picom   ] && (picom &)

# apply wallpaper after screen set
~/scripts/xdg/x.wallpaper.sh cycle &

# locker
$bgfpid ~/.luarocks/bin/mxctl.control "cmd autolockd_xautolock"

# keyboard and mouse
setxkbmap us
xsetroot -cursor_name left_ptr
