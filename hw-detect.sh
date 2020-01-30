#!/bin/sh

case $1 in
    elan)
        dev=$(ip link | grep -Po '(?<=[0-9]: )(enp.*)(?=: )')
        ;;
    wlan)
        dev=$(ip link | grep -Po '(?<=[0-9]: )(wlp.*)(?=: )')
        ;;
    bat-cap)
        dev=$(acpi -bi | grep -Po '(?<=ing, )(.*?)(?=%)')
        ;;
    bat-full-cap)
        dev=$(acpi -bi | grep -Po '(?<=last full capacity )(.*?)(?= mAh )')
        ;;
    bat-design-cap)
        dev=$(acpi -bi | grep -Po '(?<=design capacity )(.*?)(?= mAh)')
        ;;
esac

echo $dev
