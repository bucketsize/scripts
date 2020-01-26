#!/bin/sh
. ~/scripts/common.sh

require 'wget'
require 'feh'
require 'xmllint'

setUpWallpaper() {
    WALLPAPERS="$HOME/.cache/wallpapers"

    [ ! -d $WALLPAPERS ] &&  mkdir -p $WALLPAPERS

    rndn=$(od -A n -t d -N 1 /dev/urandom)
    idx=$((1 + rndn % 2000))
    url="https://www.bing.com/HPImageArchive.aspx?format=xml&idx=$idx&n=1"

    ipath=$(curl -s "$url" | xmllint --xpath "//image/url/text()" -)
    iname=$(echo $ipath | sed "s/\//\./g")
    wname="$WALLPAPERS/$iname"

    wget "http://www.bing.com/$ipath" -O "$wname" &&
        exec feh --bg-scale "$wname"

    if [ "$" != "0" ]; then
        wname=$(find "$WALLPAPERS/" -type f | shuf | head -n 1) && exec feh --bg-scale "$wname"
    fi

}

case $1 in
    start)
        launch setUPWallpaper
        ;;

    stop)
        ;;
esac

