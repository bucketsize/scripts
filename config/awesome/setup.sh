#!/bin/sh

case $1 in
	copycats)
		cd copycats/
		cat ../my/copycats.diff | git apply
		rm ./rc.lua
		ln -s ../my/copycats.rc.lua ./rc.lua
		;;
	my)
		cd my/
		ln -s ../my/rc.lua ./
		;;
esac

ln -s ../my/awesome-switcher/ ./
cd ..
