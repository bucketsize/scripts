#!/bin/sh
. ~/scripts/common.sh

require '/usr/lib/xfce4/xfce-polkit'
case $1 in
    start)
        launch /usr/lib/xfce4/xfce-polkit
        ;;
    stop)
        killall xfce-polkit
        ;;
esac
