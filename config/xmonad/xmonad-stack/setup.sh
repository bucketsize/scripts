#!/bin/sh

function clean() {
		rm *.zip
		rm xmonad-master/ xmonad-contrib-master/ xmobar-master/ -rf
		rm xmonad-x86_64-linux xmonad.o xmonad.hi xmonad.errors
}

case $1 in
	install)
		[ ! -d ~/.cache ] &&  mkdir -p ~/.cache
		[ ! -d ~/.theme ] &&  mkdir -p ~/.theme

		rm ~/.Xresources
		rm ~/.xmonad
		rm ~/.config/xmobar

		ln -s ~/scripts/config/Xresources ~/.Xresources
		ln -s ~/scripts/config/xmonad/xmonad-stack/ ~/.xmonad
		ln -s ~/scripts/config/xmobar/my ~/.config/xmobar
		;;

	install-deps)
		clean

		wget -O xmonad.zip https://github.com/xmonad/xmonad/archive/master.zip
		wget -O xmonad-contrib.zip https://github.com/xmonad/xmonad-contrib/archive/master.zip
		wget -O xmobar.zip https://github.com/jaor/xmobar/archive/master.zip

		unzip xmonad.zip
		unzip xmonad-contrib.zip
		unzip xmobar.zip

		stack install
		;;

	clean)
		clean
		;;
esac


