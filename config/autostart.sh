#!/bin/sh

bgfpid=~/scripts/bgfpid

$bgfpid sxhkd "-c ~/.config/sxhkd/sharedrc ~/.config/sxhkd/bspwmrc"

sleep 1
$bgfpid tint2
$bgfpid dunst
$bgfpid clipit
$bgfpid nm-applet --sm-disable

sleep 1
$bgfpid mpd
$bgfpid ~/local/bin/ympd "--webport 8080"
$bgfpid VBoxClient --clipboard

# jvm apps
wmname LG3D
export _JAVA_AWT_WM_NONREPARENTING=1

$bgfpid ~/.luarocks/bin/frmad.lemonbar_out '| lemonbar 
    -f "DejaVu Sans Condensed:size=9"
	-f "Font Awesome 5 Free:size=9"
	-F "#dddddd"
	-B "#87000000"'

