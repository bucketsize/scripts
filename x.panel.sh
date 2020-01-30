#!/bin/sh
. ~/scripts/common.sh

require 'tint2'
case $1 in
    start)
        launch tint2
        ;;
    stop)
        killall tint2
        ;;
esac
