#!/bin/sh

case $1 in
	findpkg)
		pacman -Ss "$2" | grep inst | awk 'NR%2 {while(pacman -Si  | getline line) if (line ~ /Ins/) {split(line,a,/:/);printf a[2]  --  }; print   }'
		;;
	findfile)
		pacman -Fy
		pacman -F "$2"
		;;
	*)
		;;
esac
