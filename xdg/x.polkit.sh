#!/bin/sh
. ~/scripts/common.sh

require 'polkit'
case $1 in
    start)
        launch polkit
        ;;
    stop)
        killall polkit
        ;;
esac
