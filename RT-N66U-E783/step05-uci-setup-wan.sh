#!/bin/sh

uci delete network.wan > /dev/null
uci delete network.wan6 > /dev/null
uci get network.@switch[0] > /dev/null || exit 1
[ "5" == "$( uci get network.@switch_vlan[5].vlan )" ] || exit 1
[ "1" == "$( uci get network.@switch[0].enable_vlan )" ] || exit 1

uci -q batch << EOF

set network.@switch_vlan[5].ports='8t 0'

set network.wan=interface
set network.wan.device='eth0.5'
set network.wan.proto='dhcp'

set network.wan6=interface
set network.wan6.device='eth0.5'
set network.wan6.proto='dhcpv6'

EOF

uci commit network || exit 1
/etc/init.d/network restart