#!/bin/sh
. ~/scripts/common.sh

require 'xautolock'
require 'i3lock'
require 'convert'

case $1 in
    start)
        launch xautolock -time 15 -locker "scripts/i3lock-fancy" -notify 30 -notifier "notify-send -u critical -t 10000 -- 'Locking screen in 30 seconds'"
        ;;
    stop)
        killall xautolock
        ;;
esac

