#!/bin/sh
. ~/scripts/common.sh

require 'tint2'
case $1 in
    start)
        launch tint2 -c $(or $2 ~/scripts/conf/my.tint2rc)
        ;;
    stop)
        killall tint2
        ;;
esac
