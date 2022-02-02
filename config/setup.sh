#!/bin/sh

. ../common.sh

install() {
    if [ "" = "$(grep '\.local\/bin' ~/.bashrc | tr -d '\n')" ]; then
        echo "\n# --" >> ~/.bashrc
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
    fi

    createdir ~/.cache
    createdir ~/.theme
    createdir ~/.wlprs
    createdir ~/.local/bin
    updatelink ~/scripts/bgfpid ~/.local/bin/bgfpid

    instlst="
    openbox
    bspwm
    sxhkd
    fontconfig
    gtk
    dunst
    tint2
    picom
    compton
    Xresources
    vim
    mpd
    mpv
    frmad
    mxctl
    ympd
    lspd
    tz
    fseer
    "

    echo $(date) > /tmp/instlst.log
    for i in $instlst; do
        echo "> setup $i"
        sh $i/setup.sh 1>>/tmp/instlst.log 2>>/tmp/instlst.log
        if [ $? != 0 ]; then
            less /tmp/instlst.log
            die "! setup failed $i"
        fi
    done

}

cleanupstale() {
    find  ~/.config \
        -type l -name "*.*" -delete
    find  ~/.local/bin \
        -type l -name "*.*" -delete
}

case $1 in
    cleanup)
        cleanupstale
        ;;
    *)
        install
        ;;
esac
