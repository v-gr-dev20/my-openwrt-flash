#!/bin/sh

uci -q batch << EOF

# network.lan=interface
set network.lan.ipaddr='192.168.40.1'

EOF

uci commit network || exit 1
reboot
