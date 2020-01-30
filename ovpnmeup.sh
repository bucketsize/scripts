#!/bin/bash

# seems this is already done by openvpn client
# logs:
#Sun Mar 29 23:57:16 2015 /sbin/ifconfig tun0 10.12.1.234 pointopoint 10.12.1.233 mtu 1500
#Sun Mar 29 23:57:18 2015 /sbin/route add -net 176.126.237.207 netmask 255.255.255.255 gw 192.168.2.1
#Sun Mar 29 23:57:18 2015 /sbin/route add -net 0.0.0.0 netmask 128.0.0.0 gw 10.12.1.233
#Sun Mar 29 23:57:18 2015 /sbin/route add -net 128.0.0.0 netmask 128.0.0.0 gw 10.12.1.233
#Sun Mar 29 23:57:18 2015 /sbin/route add -net 10.12.0.1 netmask 255.255.255.255 gw 10.12.1.233


VPNSERVER_IP=
LOCALGATEWAY_IP=192.168.2.1
TUNLOCAL_IP=

ip route add VPNSERVER_IP via LOCALGATEWAY_IP dev eth0  proto static
ip route change default via TUNLOCAL_IP dev tun0  proto static

