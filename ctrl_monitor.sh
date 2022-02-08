#!/bin/sh

vcp_bri=10
vcp_col=14

case $1 in
    bri)
        bc=$2
        if [ "$bc" = "" ] || [ $bc -lt 1 ] || [ $bc -gt 100 ]; then
            bc=80
        fi
        ddcutil setvcp $vcp_bri $bc
        ddcutil getvcp $vcp_bri
        ;;
    col)
        cv=$2
        cc=05
        case $cv in
            warm)
                cc=04
                ;;
            *)
                cc=05
                ;;
        esac
        ddcutil setvcp $vcp_col $cc
        ddcutil getvcp $vcp_col
        ;;
esac

