#!/bin/sh

switch='switch0'

uci get network.@switch[0] > /dev/null || exit 1
uci get network.@switch_vlan[6] > /dev/null && exit 0
uci get network.@switch_vlan[0] > /dev/null && exit 0

uci -q batch <<EOF

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='0'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='1'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='2'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='3'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='4'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='5'

add network switch_vlan
set network.@switch_vlan[-1]=switch_vlan
set network.@switch_vlan[-1].device='$switch'
set network.@switch_vlan[-1].vlan='6'
set network.@switch_vlan[-1].ports='8t 1 2 3 4'

set network.@switch[0].enable_vlan='1'
set network.lan.ifname='eth0.6'

EOF

uci commit network || exit 1
/etc/init.d/network restart