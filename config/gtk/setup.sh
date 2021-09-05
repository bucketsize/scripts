#!/bin/sh

case $1 in
    --diff)
        diff ~/.gtkrc-2.0 .gtkrc-2.0
        diff ~/.config/gtk-3.0/settings.ini settings.ini
        diff ~/.config/gtk-3.0/gtk.css gtk.css
        ;;
    --overwrite)
        rm ~/.gtkrc-2.0
        rm ~/.config/gtk-3.0/settings.ini
        rm ~/.config/gtk-3.0/gtk.css

        cp .gtkrc-2.0 ~/
        cp settings.ini ~/.config/gtk-3.0/
        cp gtk.css ~/.config/gtk-3.0/
        ;;
    *)
        echo "--diff | --overwrite"
        ;;
esac

