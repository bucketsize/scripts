#!/bin/sh
. ~/scripts/common.sh

require 'xautolock'

case $1 in
    start)
        launch 
        ;;
    stop)
        killall xautolock
        ;;
esac

