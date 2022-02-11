#!/bin/sh

. ../common.sh

setup_pcbell(){
    pcnobell=$(grep -Po "^set bell-style none" /etc/inputrc)
    if [ "$pcnobell" = "" ]; then
        echo "set bell-style none" | sudo tee /etc/inputrc
    fi
}

setup_path(){
    if [ "" = "$(grep '\.local\/bin' ~/.bashrc | tr -d '\n')" ]; then
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
    fi
}

setup_dirs(){
    while read -r p; do
        createdir $p
    done
}
setup_bins(){
    while read -r b; do
        updatelink ~/scripts/$b ~/.local/bin/$b
    done
}
setup_configs(){
    while read -r i; do
        echo "> setup $i"
        sh $i/setup.sh 1>>/tmp/instlst.log 2>>/tmp/instlst.log
        if [ $? != 0 ]; then
            less /tmp/instlst.log
            die "! setup failed $i"
        fi
    done
}

setup() {
    # dirs
    echo \
       "~/.cache
        ~/.theme
        ~/.wlprs
        ~/.local/bin" | setup_dirs
   
    # bins    
    echo \
        "bgfpid
         ctrl_backlight.sh
         ctrl_monitor.sh" | setup_bins

    # alternates
    # bspwm
    # compton
    # ympd
    # alacritty

    echo \
       "Xresources
        autostart
        openbox
        sxhkd
        fontconfig
        gtk
        dunst
        tint2
        picom
        vim
        mpd
        mpv
        mxctl
        lspd
        tz
        fseer
        sysctl.d" | setup_configs

    setup_pcbell
    setup_path
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
        setup
        ;;
esac
