source ../common.sh

bs=$(rndstr)

CD=~/scripts/config/gtk
CF="~/.gtkrc-2.0                  
~/.config/gtk-3.0/gtk.css     
~/.config/gtk-3.0/settings.in"

for i in $CF; do
    if [ -f $i ]; then
        mv $i $i.$bs 
    fi
done

cp $CD/.gtkrc-2.0 ~/
cp $CD/gtk.css ~/.config/gtk-3.0/
cp $CD/settings.ini ~/.config/gtk-3.0/

