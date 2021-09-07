#!/bin/sh

bgfpid=~/scripts/bgfpid

$bgfpid sxhkd "-c ~/.config/sxhkd/sharedrc ~/.config/sxhkd/bspwmrc"

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
dbus-launch --sh-syntax --exit-with-session

sleep 1
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# apply wallpaper after screen set
. ~/mxctl/env
~/.luarocks/bin/mxctl.control fun setup_video
[ -f /usr/bin/compton ] && (compton &)
[ -f /usr/bin/picom   ] && (picom &)
~/scripts/xdg/x.wallpaper.sh cycle &
$bgfpid tint2

. ~/frmad/env
$bgfpid ~/.luarocks/bin/frmad.cached "- - 2>&1 > /tmp/frmad.cached.log"
sleep 1
$bgfpid ~/.luarocks/bin/frmad.daemon "2>&1 > /tmp/frmad.daemon.log"
$bgfpid ~/.luarocks/bin/frmad.lemonbar_out '| lemonbar 
    -f "DejaVu Sans Condensed:size=9"
	-f "Font Awesome 5 Free:size=9"
	-F "#dddddd"
	-B "#87000000"'

$bgfpid ~/.luarocks/bin/mxctl.control "cmd autolockd_xautolock"

sleep 1
dunst &
clipit &
nm-applet --sm-disable &
setxkbmap us &
xsetroot -cursor_name left_ptr &

sleep 1
$bgfpid mpd
$bgfpid ~/local/bin/ympd "--webport 8080"
VBoxClient --clipboard &

# jvm apps
wmname LG3D
export _JAVA_AWT_WM_NONREPARENTING=1
