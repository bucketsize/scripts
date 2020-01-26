#!/bin/sh
. ~/scripts/common.sh

require 'dunst'
case $1 in
    start)
        launch dunst -config $(or $2 $HOME/scripts/conf/dunstrc)
        ;;
    stop)
        killall dunst
        ;;
esac
