#!/bin/sh

if [ -z "$1"]; then
    br=0.5
else
    br=$1
fi
dev=`xrandr -q | grep " connected" | cut -f 1 -d " "`
xrandr --output ${dev} --brightness ${br}
