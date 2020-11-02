#!/bin/sh

apps="display.desktop
tint2.desktop
dunst.desktop
light-locker.desktop
conky.desktop
firefox.desktop
sxhkd.desktop
picom.desktop
sys_mon.desktop
wallpaper.desktop
audio.desktop"

for i in $apps; do
	rm    ~/.config/autostart/$i
	cp $i ~/.config/autostart/$i
done
