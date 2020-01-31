#!/bin/sh
# TODO: handle multiple connected devices

blp=/sys/class/backlight
bld=$(ls $blp)
bs=$(cat $blp/$bld/brightness)
bn=$(echo "($bs+0.5)/1" | bc)
bx=0

case $1 in
    down)
        if [ $bn -gt 10 ]; then
            bx=$(echo "($bn-10)" | bc)
        fi
        ;;
    up)
        if [ $bn -lt 100 ]; then
            bx=$(echo "($bn+10)" | bc)
        fi
        ;;
esac
if [ $bx -gt 0 ]; then
    echo $bx | sudo tee $blp/$bld/brightness
fi
