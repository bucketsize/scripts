term_icon=$(find /usr/share/icons/ | grep -P "\/terminal.png" | head -1)
[ -d ~/.icons/ ] || mkdir ~/.icons
[ -h ~/.icons/terminal.png ] || ln -s $term_icon ~/.icons/terminal.png


