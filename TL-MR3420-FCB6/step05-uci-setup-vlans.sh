#!/bin/sh

uci show network.@switch[0] &> /dev/null || exit 1
while uci get network.@switch_vlan[-1] &> /dev/null ;do
	uci delete network.@switch_vlan[-1]
done

uci -q batch << EOF

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='0'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='1'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='2'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='3'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='4'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='switch0'
set network.@switch_vlan[-1].vlan='5'
set network.@switch_vlan[-1].ports='1 2 3 4 0t'

set network.@switch[0].enable_vlan='1'
set network.lan.ifname='eth0.5'

EOF

uci commit network || exit 1
/etc/init.d/network restart