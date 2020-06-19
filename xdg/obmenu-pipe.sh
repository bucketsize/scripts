#!/bin/sh

if	  [ $(which obamenu) != "" ]; then
	obamenu
elif	[ "$(which xdg_menu)" != "" ]; then
	case $1 in
		--cats)
			xdg_menu --format openbox3-pipe --root-menu /etc/xdg/menus/arch-applications.menu
			;;
		*)
			xdg_menu --format openbox3-pipe
			;;
	esac
else
	echo "<menu></menu>"
fi
