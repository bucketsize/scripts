#!/bin/sh
. ~/scripts/common.sh

require 'picom'
case $1 in
    stop)
        killall picom 
        ;;
    start)
        #compton -CcfF -I-.05 -O-.07 -D2 -t-1 -l-3 -r4.2 -o.5 &
        launch picom
        ;;
esac
