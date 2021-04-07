#!/bin/sh

uci show network.@switch[0] && exit 0
while uci delete network.@switch_vlan[-1] ;do continue ;done

uci -q batch << EOF

add network switch
set network.@switch[-1]=switch
set network.@switch[-1].name='switch0'
set network.@switch[-1].reset='1'
set network.@switch[-1].enable_vlan='0'

EOF

uci commit network || exit 1
