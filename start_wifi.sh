#!/bin/bash

ip link set wlan0 up
wpa_supplicant -i wlan0 -c <(wpa_passphrase loco miyamotomushashi)&
dhclient wlan0

