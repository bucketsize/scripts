#! /usr/bin/env sh
WALLPAPERS="$HOME/x-wallpaper"

rndn=$(od -A n -t d -N 1 /dev/urandom)

idx=$((1 + rndn % 2000))
url="https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1"
xml=$(curl "$url" -s)
ipath=$(xidel "$xml" -e "//image/url" -s)
iname=$(echo $ipath | sed "s/\//\./g")
wname="$WALLPAPERS/$iname"

echo $idx
echo $url
echo $ipath
echo $iname

wget "http://www.bing.com/$ipath" -O "$wname" &&
	exec feh --bg-scale "$wname"

#desktop_bg=$(find "$WALLPAPERS/" -type f | shuf | head -n 1) &&
#	exec feh --bg-scale "$wname"
