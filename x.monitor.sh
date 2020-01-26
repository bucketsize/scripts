#!/bin/sh
. ~/scripts/common.sh

require 'conky'

case $1 in
    start)
        launch conky --config $(or $2 $HOME/scripts/conf/conkyrc_vline)
        ;;
    stop)
        killall conky
        ;;
esac
