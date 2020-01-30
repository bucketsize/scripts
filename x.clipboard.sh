#!/bin/sh
. ~/scripts/common.sh

require 'clipit'
case $1 in
    start)
        launch clipit
        ;;
    stop)
        killall clipit
        ;;
esac
