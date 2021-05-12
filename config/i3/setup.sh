#!/bin/sh

[ ! -d ~/.cache ] &&  mkdir -p ~/.cache
[ ! -d ~/.theme ] &&  mkdir -p ~/.theme

rm ~/.config/i3
rm ~/.config/i3status
rm ~/.config/dunst
rm ~/.config/picom
rm ~/.Xresources
rm ~/lib

ln -s ~/scripts/config/i3/my ~/.config/i3
ln -s ~/scripts/config/i3status/my ~/.config/i3status
ln -s ~/scripts/config/dunst/my ~/.config/dunst
ln -s ~/scripts/config/picom/my ~/.config/picom
ln -s ~/scripts/config/Xresources ~/.Xresources
ln -s ~/scripts/lib ~/lib

