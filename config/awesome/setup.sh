#!/bin/sh

cleanup(){
	 	[ -L lain ] && rm lain
	 	[ -L freedesktop ] && rm freedesktop
	 	[ -L awesome-switcher ] && rm awesome-switcher

		ln -s ../lib/lain lain
		ln -s ../lib/awesome-freedesktop freedesktop
		ln -s ../lib/awesome-switcher awesome-switcher
		rm ~/.config/awesome
}
xbootstrap(){
	echo "exec awesome" > ~/.xinitrc
	chmod +x ~/.xinitrc

	ln -s ~/scripts/config/Xresources ~/.Xresources
}

case $1 in
	copycats)
		cd awesome-copycats/
		cleanup
		cat ../my/copycats.diff | git apply
		rm ./rc.lua
		ln -s ../my/copycats.rc.lua ./rc.lua
		ln -s ~/scripts/config/awesome/awesome-copycats ~/.config/awesome
		xbootstrap
		;;
	my)
		cd my/
		cleanup
		ln -s ~/scripts/config/awesome/my ~/.config/awesome
		xbootstrap
		;;
	floppy)
		cleanup
		ln -s ~/scripts/config/awesome/floppy ~/.config/awesome
		xbootstrap
		;;
	gnawesome)
		cleanup
		ln -s ~/scripts/config/awesome/gnawesome ~/.config/awesome
		xbootstrap
		;;
	*)
		echo "./setup.sh {my|copycats}"
		;;
esac
