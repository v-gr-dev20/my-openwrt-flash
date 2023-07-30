#!/bin/sh

uci show network.wan &>/dev/null && exit 0

uci -q batch << EOF

add network device
set network.@device[-1]=device
set network.@device[-1].name='eth1'

set network.wan=interface
set network.wan.ifname='eth1'
set network.wan.proto='static'
set network.wan.ipaddr='172.20.0.2'
set network.wan.netmask='255.255.0.0'
set network.wan.gateway='172.20.0.1'
set network.wan.ip6assign='60'

EOF

echo 001
uci commit || exit 1
#uci commit network || exit 1
echo 002
#uci commit firewall || exit 1
#/etc/init.d/network reload
/etc/init.d/network restart
#/etc/init.d/firewall restart
