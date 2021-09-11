#!/bin/sh

. ~/scripts/common.sh

githubfetch() {
    b=$(echo "$1" | cut -d"/" -f1)
    r=$(echo "$1" | cut -d"/" -f2)
    [ -d ~/$r ] || git clone https://github.com/$b/$r.git
}


pkgdep_bspwm="bspwm"
pkgdep_sxhkd="sxhkd"
pkgdep_dunst="dunst"
pkgdep_tint2="tint2"
pkgdep_picom="picom"
pkgdep_compton="compton"
pkgdep_Xresources="xrdb"
pkgdep_xinit="xhost"

wm=bspwm

createdir ~/.cache
createdir ~/.theme
createdir ~/.wlprs

# phase 1
checkpkgs "$wm lemonbar sxhkd dunst tint2 picom xrdb xhost wget curl feh xmllint"
updatelink ~/scripts/config/bspwm/my ~/.config/bspwm
updatelink ~/scripts/config/sxhkd/my ~/.config/sxhkd
updatelink ~/scripts/config/dunst/my ~/.config/dunst
updatelink ~/scripts/config/tint2/my-v ~/.config/tint2
updatelink ~/scripts/config/picom/my ~/.config/picom
updatelink ~/scripts/config/compton/my ~/.config/compton

updatelink ~/scripts/config/nvim/my ~/.config/nvim

rm ~/.Xresources
cp ~/scripts/config/Xresources/my/.Xresources ~/.Xresources
sed -i "s|__home|$HOME|g" ~/.Xresources

updatelink ~/scripts/config/xinit/my/.xinitrc ~/.xinitrc
updatelink ~/scripts/fonts ~/.fonts

# phase 2
checkpkgs "git libssl make urxvt xrandr fzy wmctrl"
githubfetch bucketsize/minilib
githubfetch bucketsize/frmad
githubfetch bucketsize/mxctl

ipwd=$(pwd)
LIBDIR=/usr/lib/$(arch)-linux-gnu
cd ~/minilib && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR
cd ~/frmad && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR 
cd ~/mxctl && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR 
cd $ipwd

# requirefiles "~/.luarocks/bin/frmad.cached
#  ~/.luarocks/bin/frmad.daemon 
#  ~/.luarocks/bin/mxctl.control"

if [ -d ~/.config/mxctl ]; then
    echo "[~/.config/mxctl] already present"
else
    createdir ~/.config/mxctl
    cp ~/scripts/config/mxctl/my/config ~/.config/mxctl/
fi
