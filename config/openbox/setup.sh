checkpkgs "openbox obconf"
updatelink ~/scripts/config/openbox/my ~/.config/openbox
[ -d ~/.themes] || mkdir ~/.themes
ln -s ~/scripts/config/openbox/themes/Tenebris/ ~/.themes/
