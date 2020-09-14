#~/bin/sh

[ ! -d ~/.cache ] &&  mkdir -p ~/.cache

rm ~/.config/bspwm
rm ~/.config/conky
rm ~/.config/dunst
rm ~/.config/sxhkd
rm ~/.config/compton.conf
rm ~/.Xresources
rm ~/lib

ln -s ~/scripts/config/bspwm/my/ ~/.config/bspwm
ln -s ~/scripts/config/conky/simple ~/.config/conky
ln -s ~/scripts/config/dunst/my ~/.config/dunst
ln -s ~/scripts/config/sxhkd/my ~/.config/sxhkd
ln -s ~/scripts/config/compton/default/compton.conf ~/.config/
ln -s ~/scripts/config/Xresources ~/.Xresources
ln -s ~/scripts/lib ~/lib
