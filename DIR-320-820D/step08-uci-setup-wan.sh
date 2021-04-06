#!/bin/sh

uci show network.wan && exit 0
uci show network.@switch[0] || exit 1
[ "5" == "$( uci show network.@switch_vlan[5].vlan |sed 's/^.*\='\''\(.*\)'\''$/\1/' )" ] || exit 1
[ "1" == "$( uci show network.@switch[0].enable_vlan |sed 's/^.*\='\''\(.*\)'\''$/\1/' )" ] || exit 1

uci -q batch << EOF

set network.@switch_vlan[5].ports='0 5t'

set network.wan=interface
set network.wan.ifname='eth0.5'
set network.wan.proto='dhcp'

EOF

uci commit network || exit 1
/etc/init.d/network restart