#!/bin/sh

source ../common.sh

install() {
    if [ "" = "$(grep '\.local\/bin' ~/.bashrc | tr -d '\n')" ]; then
        echo "\n# --" >> ~/.bashrc
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
    fi

    createdir ~/.cache
    createdir ~/.theme
    createdir ~/.wlprs
    createdir ~/.local/bin

    instlst="
    openbox
    bspwm
    sxhkd
    fontconfig
    gtk
    dunst
    tint2
    picom
    Xresources
    vim
    mpd
    mpv
    frmad
    mxctl
    "

    optlst="
    ympd
    compton
    "

    for i in $instlst; do
        echo "---> setup %i"
        sh $i/setup.sh
    done

    updatelink ~/scripts/bgfpid ~/.local/bin/bgfpid
}

cleanupstale() {
    for i in openbox bspwm compton dunst mpd ympd mpv vim picom tint2 sxhkd; do
        rm ~/.config/$i\.*
    done
}

case $1 in
    cleanupstale)
        cleanupstale
        ;;
    *)
        install
        ;;
esac
