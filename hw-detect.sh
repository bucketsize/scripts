#!/bin/sh

case $1 in
    lan)
        dev=$(ip link | grep -Po '(?<=[0-9]: )(enp.*)(?=: )')
        ;;
    wlan)
        dev=$(ip link | grep -Po '(?<=[0-9]: )(wlp.*)(?=: )')
        ;;
esac

echo $dev
