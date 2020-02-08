#!/bin/sh
. ~/scripts/common.sh

require 'i3lock'
require 'convert'
require 'import'

set -o errexit -o noclobber -o nounset

# default system sans-serif font
font=$(convert -list font | awk "{ a[NR] = \$2 } /family: $(fc-match sans -f "%{family}\n")/ { print a[NR-1]; exit }")
icon_dir=~/scripts/icons
value=70
image=$(mktemp --suffix=.png)
i3lock_cmd="i3lock -i $image"
text="Type password to unlock"
import -window root $image
color=$(convert "$image" -gravity center -crop 100x100+0+0 +repage -colorspace hsb \
    -resize 1x1 txt:- | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}');
if [ $color -gt $value ]; then #white background image and black text
    bw="black"
    icon="$icon_dir/lockdark.png"
else #black
    bw="white"
    icon="$icon_dir/lock.png"
fi

convert $image \
	-level 0%,100%,0.6 \
	-filter Gaussian -resize 20% -define filter:sigma=1.5 -resize 500.5% \
	-font $font -pointsize 26 \
 	-fill $bw -gravity center \
	-annotate +0+160 "$text" $icon -gravity center \
 	-composite $image

# kill monitor after 60s
(sleep 60s; pgrep i3lock && xset dpms force off) &
i3lock -i $image
