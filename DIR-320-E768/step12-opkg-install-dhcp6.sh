#!/bin/sh

opkg update || exit 1
opkg install odhcp6c odhcpd-ipv6only

[ 0 -eq $? ] || exit 1
/etc/init.d/network restart