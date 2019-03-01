 #! /usr/bin/env sh
 WALLPAPERS="$HOME/x-wallpaper"

 echo "WALLPAPERS=$WALLPAPERS"
 find -type f $WALLPAPERS | wc -l

 desktop_bg=$(find "$WALLPAPERS/" -type f | shuf | head -n 1) &&
 exec feh --bg-scale "$desktop_bg"
