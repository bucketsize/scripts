#!/bin/sh
. ~/scripts/common.sh

require 'scrot'

DATE=`date +%Y-%m-%dT%H:%M:%S`
#import -window root "$HOME/Desktop/screenshot-$DATE.png"

if [! -d ~/Pictures/Screenshots ]; then
    mkdir  ~/Pictures/Screenshots
fi

case $1 in
    prompt)
        scrot -s ~/'Pictures/Screenshots/scrot-$DATE.png'
        ;;
    *)
        scrot ~/'Pictures/Screenshots/scrot-$DATE.png'
        ;;
}
