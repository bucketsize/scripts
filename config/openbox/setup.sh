#!/bin/sh

[ ! -d ~/.cache ] &&  mkdir -p ~/.cache

rm ~/.config/openbox
rm ~/.config/tint2
rm ~/.config/conky
rm ~/.config/dunst
rm ~/.config/sxhkd
rm ~/.config/compton.conf
rm ~/.config/awesome

ln -s ~/scripts/config/openbox/my ~/.config/openbox
ln -s ~/scripts/config/tint2/my-v ~/.config/tint2
ln -s ~/scripts/config/conky/my ~/.config/conky
ln -s ~/scripts/config/dunst/my ~/.config/dunst
ln -s ~/scripts/config/compton/my/compton.conf ~/.config/
