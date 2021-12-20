#!/bin/sh
. ~/scripts/common.sh

rm ~/.vimrc
ln -s ~/scripts/config/vim/vimrc ~/.vimrc
updatelink ~/scripts/tvim ~/.local/bin/tvim
