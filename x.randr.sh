#!/bin/sh
. ~/scripts/common.sh

require 'xrandr'
require 'xset'
require 'xrdb'

xinfo=$(xrandr -q)
dev=$(echo "$xinfo" | grep -Po '(?<=^)(.*?)(?= connected)')
res=$(echo "$xinfo" | grep -Po '(?<= )([[:digit:]]{4}x[[:digit:]]{3})(?= )' | head -n1)
xrandr --output $dev --mode $res --pos 0x0 --rotate normal
xset -b
xrdb -I~/scripts/config/Xresources.d -merge ~/scripts/config/Xresources
