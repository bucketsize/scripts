#!/bin/sh

# local typed k,v store
(sleep 1; ~/.luarocks/bin/frmad.cached - -) &

# monitoring daemon
export openweathermap_apikey=16704e3405a0cb1a1ae1b7917e4ff2fd
(sleep 2; ~/.luarocks/bin/frmad.daemon) &

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
(sleep 1; dbus-launch --sh-syntax --exit-with-session)
(sleep 2; dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY)

# apply wallpaper after screen set
(sleep 3; ~/.luarocks/bin/mxctl.control fun setup_video)
(sleep 3; ~/scripts/xdg/x.wallpaper.sh cycle) &

(sleep 4; ~/.luarocks/bin/mxctl.control cmd autolockd_xautolock) &
(sleep 5; picom) &
(sleep 5; dunst) &
(sleep 5; clipit) &
(sleep 5; nm-applet --sm-disable) &
(sleep 5; setxkbmap us) &
(sleep 3; xsetroot -cursor_name left_ptr) &
(sleep 5; VBoxClient --clipboard) &
