#!/bin.sh
. ~/scripts/common.sh

require 'xkill'
require 'amixer'
require 'sxhkd'

case $1 in
    start)
        launch sxhkd -c ~/scripts/conf/sxhkdrc
        ;;
    stop)
        killall sxhkd
        ;;
esac
