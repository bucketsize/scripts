#!/bin/sh

bc=$1
if [ "$bc" = "" ] || [ $bc -lt 1 ] || [ $bc -gt 100 ]; then
    echo "expect between (0, 100]"
    exit 10
fi

bl=/sys/class/backlight
ls $bl | while read x; do
    read -r max < $bl/$x/max_brightness
    read -r cur < $bl/$x/brightness
    exp=$((bc * max / 100))
    echo "$x: $cur / $max -> $exp / $max"
    echo $exp > $bl/$x/brightness 
done
