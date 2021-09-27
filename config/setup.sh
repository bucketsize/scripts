#!/bin/sh

. ~/scripts/common.sh

install() {
    if [ "" = "$(grep '\.local\/bin' ~/.bashrc | tr -d '\n')" ]; then
        echo "\n# --" >> ~/.bashrc
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
    fi

    createdir ~/.cache
    createdir ~/.theme
    createdir ~/.wlprs
    createdir ~/.local/bin

    . openbox/setup.sh
    . bspwm/setup.sh
    . sxhkd/setup.sh
    . dunst/setup.sh
    . tint2/setup.sh
    . picom/setup.sh
    . compton/setup.sh
    . Xresources/setup.sh
    . nvim/setup.sh
    . mpd/setup.sh
    #. ympd/setup.sh
    . mpv/setup.sh
    #. frmad/setup.sh
    #. mxctl/setup.sh

    updatelink ~/scripts/bgfpid ~/.local/bin/bgfpid
}

cleanupstale() {
    rm ~/.config/{bspwm,compton,dunst,mpd,ympd,mpv,nvim,picom,tint2,sxhkd}.*
}

case $1 in
    cleanupstale)
        cleanupstale
        ;;
    *)
        install
        ;;
esac
