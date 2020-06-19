#!/bin/sh
. ~/scripts/common.sh

require 'wget'
require 'feh'
require 'xmllint'

WALLPAPERS="$HOME/Wallpapers"
WALLPAPER=$WALLPAPERS/wallpaper

setUpWallpaper() {
	[ ! -d $WALLPAPERS ] &&  mkdir -p $WALLPAPERS

	rndn=$(od -A n -t d -N 1 /dev/urandom)
	idx=$((1 + rndn % 2000))
	url="https://www.bing.com/HPImageArchive.aspx?format=xml&idx=$idx&n=1"

	xresp=$(curl -s "$url")
	echo "$xresp"
	ipath=$(echo $xresp | xmllint --xpath "//image/url/text()" -)
	iname=$(echo $ipath | grep -Po '(?<=id=)(.+?)(?=&)')
	if [ "$iname" == "" ]; then
		iname="$rndn"
	fi
	wname="$WALLPAPERS/$iname"

	wget "http://www.bing.com/$ipath" -O "$wname"
	if [ "$" != "0" ]; then
		wname=$(find "$WALLPAPERS/" -type f | shuf | head -n 1)
	fi

	rm $WALLPAPER
	ln -s "$wname" $WALLPAPER
	feh --bg-scale "$wname"
}

setupWebWallpaper(){
	query=$1
	url="https://duckduckgo.com/?q=$query&t=h_&iax=images&ia=images&iaf=size:Wallpaper"
	curl -XGET $url
}

setUpWallpaper

