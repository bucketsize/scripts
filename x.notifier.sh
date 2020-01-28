#!/bin/sh
. ~/scripts/common.sh

require 'dunst'
case $1 in
    start)
        launch dunst
        ;;
    stop)
        killall dunst
        ;;
esac
