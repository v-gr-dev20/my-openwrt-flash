#!/bin/sh

uci get network.wan > /dev/null && exit 0
uci get network.@switch[0] > /dev/null || exit 1
[ "5" == "$( uci get network.@switch_vlan[5].vlan )" ] || exit 1
[ "1" == "$( uci get network.@switch[0].enable_vlan )" ] || exit 1

uci -q batch << EOF

set network.@switch_vlan[5].ports='0 5t'

set network.wan=interface
set network.wan.ifname='eth0.5'
set network.wan.proto='dhcp'

EOF

uci commit network || exit 1
/etc/init.d/network restart