#!/bin/sh
. ~/scripts/common.sh

require 'xrandr'
require 'xset'
require 'xrdb'

xrandr --output default --mode 1368x768 --pos 0x0 --rotate normal
xset -b
xrdb -merge $HOME/scripts/conf/Xresources
[ ! -d $HOME/.cache ] &&  mkdir -p $HOME/.cache
