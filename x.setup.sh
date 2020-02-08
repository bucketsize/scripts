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
ln -s ~/scripts/config/tint2/my ~/.config/tint2
ln -s ~/scripts/config/conky/dials ~/.config/conky
ln -s ~/scripts/config/dunst/my ~/.config/dunst
ln -s ~/scripts/config/sxhkd/my ~/.config/sxhkd
ln -s ~/scripts/config/compton/my/compton.conf ~/.config/

ln -s ~/scripts/config/awesome/my/ ~/.config/awesome


