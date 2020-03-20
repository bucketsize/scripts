#!/bin/sh
. ~/scripts/common.sh

require 'xautolock'

case $1 in
    start)
        launch xautolock -time 15 -locker "~/scripts/x.lock-i3.sh" -notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking screen in 30 seconds'"
        ;;
    stop)
        killall xautolock
        ;;
esac

