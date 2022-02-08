#!/bin/sh

. ../common.sh

setup_compile() {
    checkpkgs "xcb
     xcb-randr
     xft 
     x11-xcb
     xcb-xinerama"

    if [ -d ~/lemonbar-xft ]; then
        cd ~/lemonbar-xft
        git pull
    else
        cd ~/
        git clone https://gitlab.com/protesilaos/lemonbar-xft.git
        cd ~/lemonbar-xft
    fi
    make
    tar -czf lemonbar.$(arch).tar.gz lemonbar
    cp -fv lemonbar ~/.local/bin/
}

setup_prebuilt() {
    pkg=lemonbar.$(arch).tar.gz
    cd /tmp
    wget https://www.dropbox.com/s/hxuj4yz0x0vvrfj/$pkg 
    tar -xvzf $pkg -C ~/.local/bin
}

setup_compile
