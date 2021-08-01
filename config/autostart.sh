#!/bin/sh

# local typed k,v store
(sleep 1; ~/scripts/sys_mon/cached.lua > /var/tmp/cached.log) &
(sleep 2; ~/scripts/sys_mon/daemon.lua > /var/tmp/daemon.log) &

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
(sleep 1; dbus-launch --sh-syntax --exit-with-session)
(sleep 2; dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY)

# apply wallpaper after screen set
(sleep 3; ~/scripts/sys_mon/control.lua fun setup_video)
(sleep 3; ~/scripts/xdg/x.wallpaper.sh cycle) &

(sleep 4; ~/scripts/sys_mon/control.lua cmd autolockd_xautolock) &
(sleep 5; picom) &
(sleep 5; dunst) &
(sleep 5; clipit) &
(sleep 5; nm-applet --sm-disable) &
(sleep 5; setxkbmap us) &
(sleep 5; VBoxClient --clipboard) &

