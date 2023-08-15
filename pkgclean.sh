#!/bin/sh

case $1 in 
	clearall)
		sudo pacman -Scc
		;;
	clear)
		sudo pacman -Sc
		;;
	*)
		;;	
esac
