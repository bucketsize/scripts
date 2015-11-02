#!/bin/bash
bf=$1
dev=`xrandr -q | grep " connected" | cut -f 1 -d " "`
echo "setting lum for ${dev} to ${bf}"
xrandr --output ${dev} --brightness ${bf}
