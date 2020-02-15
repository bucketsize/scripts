#!/bin/sh

case $1 in
	copycats)
		cd awesome-copycats/

	 	[ -f lain ] && rm lain
	 	[ -f freedesktop ] && rm freedesktop

		ln -s ../lib/lain lain
		ln -s ../lib/awesome-freedesktop freedesktop
		ln -s ../lib/awesome-switcher awesome-switcher

		cat ../my/copycats.diff | git apply

		rm ./rc.lua
		ln -s ../my/copycats.rc.lua ./rc.lua

		rm ~/.config/awesome
		ln -s ~/scripts/config/awesome/awesome-copycats ~/.config/awesome

		;;
	my)
		cd my/
	 	
		[ -f lain ] && rm lain
	 	[ -f freedesktop ] && rm freedesktop
	 	[ -f awesome-switcher ] && rm awesome-switcher
		
		ln -s ../lib/lain lain
		ln -s ../lib/awesome-freedesktop freedesktop
		ln -s ../lib/awesome-switcher awesome-switcher

		rm ~/.config/awesome
		ln -s ~/scripts/config/awesome/my ~/.config/awesome
		;;
esac
