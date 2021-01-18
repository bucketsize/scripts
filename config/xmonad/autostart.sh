#!/bin/sh

source ~/.bashrc
xrdb -merge ~/.Xresources
sleep 4; trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --tint 0x000000 --height 20 &
sleep 4; nm-applet --sm-disable &
sleep 2; ~/scripts/sys_ctl/ctl.lua fun pa_set_default &
sleep 2; ~/scripts/sys_ctl/ctl.lua cmd dtop_viga &
sleep 2; dunst &
sleep 1; ~/scripts/sys_ctl/ctl.lua cmd autolockd_xautolock &
sleep 1; picom -cb &
sleep 2; ~/scripts/sys_mon/daemon.lua &
sleep 3; ~/scripts/xdg/x.wallpaper.sh cycle &
