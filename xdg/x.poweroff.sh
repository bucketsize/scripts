#!/bin/sh
. ~/scripts/common.sh

require 'zenity'
require 'pm-suspend'
require 'pm-hibernate'

# gtk ux
popt=$(zenity --width=200 --height=100 --list --column "F" --title="choice" "Logout" "Suspend" "Hibernate" "Reboot" "PowerOff" --hide-header --modal)

# terminal ux
# poptf=/tmp/.poptf
# st -g 40x20 -e dialog --no-shadow --no-ok --no-cancel --clear --colors --backtitle "Power" --title "Options" --menu "" 10 30 3 Suspend "" Poweroff "" Hibernate "" 2> $poptf
# popt=$(cat $poptf)

logout(){
    require 'openbox'

    #TODO: start using dbus / lightdm
    case $XDG_SESSION_DESKTOP in
        openbox)
            openbox --exit
            ;;
        *)
            echo "don't know how to logout"
            notify-send "don't know how to logout"
    esac
}

case $popt in
    Logout)
        gsudo logout
        ;;
    # start using dbus, upowerd
    Suspend)
        gsudo pm-suspend
        ;;
    Hibernate)
        gsudo pm-hibernate
        ;;
    Reboot)
        gsudo reboot
        ;;
    Poweroff)
        gsudo poweroff
        ;;
esac
