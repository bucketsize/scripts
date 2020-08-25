#!/bin/sh

ow=''
while true; do
	wi=`xdotool getactivewindow`
	aw=`xdotool getwindowname $wi`
	if [ "$aw" != "$ow" ]; then
		dt=`date +%Y-%m-%dT%H:%M:%S%z`
		echo "$dt : $aw"
		ow="$aw"
	fi
	sleep 1
done


