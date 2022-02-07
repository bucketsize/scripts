#!/bin/sh

# maybe / maybe not
export PATH=~/.local/bin:$PATH

# nice things
xrdb -merge ~/.Xresources

# dbus for dbus aware apps integration . ie pulseaudio, nautilus, firefox, dunst
dbus-launch --sh-syntax --exit-with-session
sleep 1
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# monitoring
bgfpid ~/.luarocks/bin/frmad.cached "- - 2>&1 > /tmp/frmad.cached.log"
sleep 1
bgfpid ~/.luarocks/bin/frmad.daemon "2>&1 > /tmp/frmad.daemon.log"

#screen
~/.luarocks/bin/mxctl.control fun setup_video

if [ "$(which picom)" = "" ]; then
    bgfpid compton
else
    bgfpid picom
fi

# apply wallpaper after screen set
~/.luarocks/bin/mxctl.control fun applywallpaper

# locker
#$bgfpid ~/.luarocks/bin/mxctl.control "cmd autolockd_xautolock"

# keyboard and mouse
setxkbmap us
xsetroot -cursor_name left_ptr

bgfpid sxhkd "-c ~/.config/sxhkd/sharedrc"

sleep 1
bgfpid tint2
bgfpid dunst
bgfpid clipit
bgfpid nm-applet --sm-disable
bgfpid lxpolkit

sleep 1
bgfpid mpd
bgfpid ~/local/bin/ympd "--webport 8080"
bgfpid VBoxClient --clipboard

# jvm apps
wmname LG3D
export _JAVA_AWT_WM_NONREPARENTING=1

bgfpid fseer.$(arch) ' lemonbar | lemonbar 
    -f "DejaVu Sans Condensed:size=9"
	-f "Font Awesome 5 Free:size=9"
	-F "#dddddd"
	-B "#87000000"'

# flatpak run com.valvesoftware.Steam
