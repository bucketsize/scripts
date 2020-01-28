#!/bin/sh
. ~/scripts/common.sh

require 'conky'

case $1 in
    start)
        launch conky
        ;;
    stop)
        killall conky
        ;;
esac
