#~/bin/sh

#!/bin/sh

[ ! -d ~/.cache ] &&  mkdir -p ~/.cache
[ ! -d ~/.theme ] &&  mkdir -p ~/.theme

rm ~/.config/bspwm
rm ~/.config/sxhkd
rm ~/.config/dunst
rm ~/.config/picom
rm ~/.config/compton
rm ~/.Xresources
rm ~/.xinitrc
rm ~/lib
rm ~/.fonts

ln -s ~/scripts/config/bspwm/my ~/.config/bspwm
ln -s ~/scripts/config/sxhkd/my ~/.config/sxhkd
ln -s ~/scripts/config/dunst/my ~/.config/dunst
ln -s ~/scripts/config/picom/my ~/.config/picom
ln -s ~/scripts/config/compton/my ~/.config/compton
ln -s ~/scripts/config/Xresources ~/.Xresources
ln -s ~/scripts/config/xinitrc ~/.xinitrc
ln -s ~/scripts/lib ~/lib
ln -s ~/scripts/fonts ~/.fonts
