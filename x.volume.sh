#!/bin/bash

switch_audio(){
    dev=$(pactl list sinks | grep "active profile"| cut -d ' ' -f 3-)
    if [ "$dev" = "analog-output;output-speaker" ] ; then
        pactl set-sink-port 0 "analog-output;output-headphones-1"
        notify-send -u low -t 2000 -c Pulseaudio "Headphone"
        notify-send --title "Pulseaudio" --passivepopup "Headphone" 2 
    else
        pactl set-sink-port 0 "analog-output;output-speaker"      
        notify-send -u low -t 2000 -c Pulseaudio "Speaker"
    fi
}
vol_up(){
    pactl set-sink-volume 0 +10%
    notify-send -u low -t 2000 -c Pulseaudio "Volume +10%"
}
vol_down(){
    pactl set-sink-volume 0 -10%
    notify-send -u low -t 2000 -c Pulseaudio "Volume -10%"
}
vol_toggle(){
    pactl set-sink-mute 0 true
    notify-send -u low -t 2000 -c Pulseaudio "Volume toggle"
}
case $1 in
    up)
        vol_up
        ;;
    down)
        vol_down
        ;;
    switch)
        switch_audio
        ;;
    start)
	pulseaudio --start
	;;
    stop)
	pulseaudio --kill
	;;
    status)
	pactl info 
	;;
esac

