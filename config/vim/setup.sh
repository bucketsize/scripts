#!/bin/sh

rm ~/.vimrc
rm ~/.vimrc.local
rm ~/.vimrc.local.bundles

ln -s ~/scripts/config/vim/vimrc ~/.vimrc
ln -s ~/scripts/config/vim/vimrc.local ~/.vimrc.local
ln -s ~/scripts/config/vim/vimrc.local.bundles ~/.vimrc.local.bundles
