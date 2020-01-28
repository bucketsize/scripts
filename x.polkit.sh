#!/bin/sh
. ~/scripts/common.sh

require 'lxpolkit'
case $1 in
    start)
        launch lxpolkit
        ;;
    stop)
        killall lxpolkit
        ;;
esac
