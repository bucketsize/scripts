#!/bin/sh

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
dbus-launch --sh-syntax --exit-with-session

sleep 1
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# local typed k,v store
~/.luarocks/bin/frmad.cached - - 2>&1 > /tmp/frmad.cached.log &

# monitoring daemon
sleep 1
~/.luarocks/bin/frmad.daemon 2>&1 > /tmp/frmad.daemon.log &


# apply wallpaper after screen set
~/.luarocks/bin/mxctl.control fun setup_video
~/scripts/xdg/x.wallpaper.sh cycle &

~/.luarocks/bin/mxctl.control cmd autolockd_xautolock &
(if [ -f /usr/bin/picom ];
then picom;
else compton;
	fi) &

sleep 1
dunst &
clipit &
nm-applet --sm-disable &
setxkbmap us &
xsetroot -cursor_name left_ptr &

sleep 1
(if [ -f /usr/bin/VBoxClient ];
then VBoxClient --clipboard;
	fi)	&
