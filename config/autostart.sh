#!/bin/sh

(sleep 1; dbus-launch --sh-syntax --exit-with-session) &
(sleep 2; dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY) &
(sleep 3; ~/scripts/sys_ctl/ctl.lua cmd display1_on) &
(sleep 3; ~/scripts/sys_ctl/ctl.lua cmd display2_off) &
(sleep 4; ~/scripts/xdg/x.wallpaper.sh cycle) &
(sleep 4; ~/scripts/sys_ctl/ctl.lua fun pa_set_default) &
(sleep 4; ~/scripts/sys_ctl/ctl.lua cmd autolockd_xautolock) &
(sleep 5; picom) &
(sleep 5; dunst) &
(sleep 5; clipit) &
(sleep 5; nm-applet --sm-disable) &
(sleep 5; setxkbmap us) &
(sleep 5; VBoxClient --clipboard) &

