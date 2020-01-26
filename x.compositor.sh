#!/bin/sh
. ~/scripts/common.sh

require 'compton'
case $1 in
    stop)
        killall compton
        ;;
    start)
        #compton -CcfF -I-.05 -O-.07 -D2 -t-1 -l-3 -r4.2 -o.5 &
        launch compton
        ;;
esac
