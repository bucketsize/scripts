#!/bin/sh
. ~/scripts/common.sh

require 'nm-applet'
case $1 in
    start)
        launch nm-applet
        ;;
    stop)
        killall nm-applet
        ;;
esac
