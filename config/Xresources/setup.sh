checkpkgs "xrdb"

rm ~/.Xresources
cp ~/scripts/config/Xresources/my/.Xresources ~/.Xresources
sed -i "s|__home|$HOME|g" ~/.Xresources
