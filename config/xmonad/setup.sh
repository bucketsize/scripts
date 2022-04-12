#!/bin/sh

rm ~/.xmonad
ln -s $(pwd)/xmonad/xmonad-stack/ ~/.xmonad

rm ~/.config/xmobar
ln -s $(pwd)/xmobar/my ~/.config/xmobar

build_dir=$(pwd)/xmonad/xmonad-stack
[ -d $build_dir ] || mkdir -p $build_dir

cd $build_dir
if [ ! -f xmonad.zip ]; then
	rm -v *.zip
	rm -v {xmonad-master,xmonad-contrib-master,xmobar-master} -rf
	rm -v {xmonad-x86_64-linux,xmonad.o,xmonad.hi,xmonad.errors}

	wget -O xmonad.zip https://github.com/xmonad/xmonad/archive/master.zip
	wget -O xmonad-contrib.zip https://github.com/xmonad/xmonad-contrib/archive/master.zip
	wget -O xmobar.zip https://github.com/jaor/xmobar/archive/master.zip

	unzip xmonad.zip
	unzip xmonad-contrib.zip
	unzip xmobar.zip
fi

stack install
