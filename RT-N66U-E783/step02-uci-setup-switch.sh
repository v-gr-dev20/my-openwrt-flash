#!/bin/sh

while uci delete network.@switch[-1] 2> /dev/null ;do continue ;done
switch='switch0'
uci get network.@switch[0] > /dev/null && exit 0
while uci delete network.@switch_vlan[-1] 2> /dev/null ;do continue ;done

uci -q batch << EOF

add network switch
set network.@switch[-1]=switch
set network.@switch[-1].name='$switch'
set network.@switch[-1].reset='1'
set network.@switch[-1].enable_vlan='0'

EOF

uci delete network.wan.ifname
uci delete network.wan6.ifname

uci commit network || exit 1