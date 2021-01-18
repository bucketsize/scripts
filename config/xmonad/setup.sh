#!/bin/sh

[ ! -d ~/.cache ] &&  mkdir -p ~/.cache
[ ! -d ~/.theme ] &&  mkdir -p ~/.theme

rm ~/.Xresources
rm ~/.xmonad
rm ~/.config/xmobar

ln -s ~/scripts/config/Xresources ~/.Xresources
ln -s ~/scripts/config/xmonad/my ~/.xmonad
ln -s ~/scripts/config/xmobar/my ~/.config/xmobar
