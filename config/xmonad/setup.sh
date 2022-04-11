#!/bin/sh

build_dir=$(pwd)/xmonad/xmonad-stack

[ -d $build_dir ] || mkdir -p $build_dir

# rm -v $build_dir/*.zip
# rm -v $build_dir/{xmonad-master,xmonad-contrib-master,xmobar-master} -rf
# rm -v $build_dir{xmonad-x86_64-linux,xmonad.o,xmonad.hi,xmonad.errors}

# wget -O xmonad.zip https://github.com/xmonad/xmonad/archive/master.zip
# wget -O xmonad-contrib.zip https://github.com/xmonad/xmonad-contrib/archive/master.zip
# wget -O xmobar.zip https://github.com/jaor/xmobar/archive/master.zip

# unzip xmonad.zip
# unzip xmonad-contrib.zip
# unzip xmobar.zip

# rm ~/.xmonad
# ln -s $(pwd)/xmonad/xmonad-stack/ ~/.xmonad

# rm ~/.config/xmobar
# ln -s $(pwd)/xmobar/my ~/.config/xmobar

cd $build_dir
stack install
