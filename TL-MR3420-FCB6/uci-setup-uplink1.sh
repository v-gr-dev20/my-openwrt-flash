#!/bin/sh

uci show network.@switch[0] &> /dev/null || exit 1
uci show network.@switch_vlan[1] &> /dev/null || exit 1
uci show network.@switch_vlan[5] &> /dev/null || exit 1
[ "lan" == "$( uci get firewall.@zone[0].name )" ] || exit 1

uci -q batch << EOF

set network.@switch_vlan[1].ports='1 0t'
set network.@switch_vlan[5].ports='2 3 4 0t'

set network.uplink1='interface'
set network.uplink1.proto='static'
set network.uplink1.ifname='eth0.1'
set network.uplink1.ipaddr='192.168.1.20'
set network.uplink1.netmask='255.255.255.0'

del firewall.@zone[0].network
add_list firewall.@zone[0].network='lan'
add_list firewall.@zone[0].network='uplink1'

EOF

uci commit network || exit 1
uci commit firewall || exit 1
/etc/init.d/network restart