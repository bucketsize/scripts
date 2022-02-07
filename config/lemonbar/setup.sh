#!/bin/sh

. ../common.sh

setup_compile() {
    if [ -d ~/lemonbar-xft/.git ]; then
        cd ~/lemonbar-xft
        git pull
    else
        cd ~/
        git clone https://gitlab.com/protesilaos/lemonbar-xft.git
        cd ~/lemonbar-xft
    fi
    make
    tar -czf lemonbar.$(arch).tar.gz lemonbar
}

setup_prebuilt() {
    pkg=lemonbar.$(arch).tar.gz
    cd /tmp
    wget https://www.dropbox.com/s/hxuj4yz0x0vvrfj/$pkg 
    tar -xvzf $pkg -C ~/.local/bin
}
