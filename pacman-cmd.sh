#!/bin/sh

case $1 in
	clear-cache)
		sudo pacman -Sc
		;;
esac


