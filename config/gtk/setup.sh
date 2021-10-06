#!/bin/sh
. ~/scripts/common.sh

bs=$(rndstr)
mv ~/.gtkrc-2.0                   ~/.gtkrc-2.0.$bs                   
mv ~/.config/gtk-3.0/gtk.css      ~/.config/gtk-3.0/gtk.css.$bs 
mv ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.$bs 

cp .gtkrc-2.0 ~/
cp gtk.css ~/.config/gtk-3.0/
cp settings.ini ~/.config/gtk-3.0/

