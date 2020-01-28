#!/bin.sh
. ~/scripts/common.sh

require 'xkill'
require 'amixer'
require 'sxhkd'

case $1 in
    start)
        launch sxhkd
        ;;
    stop)
        killall sxhkd
        ;;
esac
