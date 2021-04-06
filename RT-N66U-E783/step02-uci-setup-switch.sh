#!/bin/sh


getSwitch()
{
	swconfig list |sed 's/^\S\+\s\+\(\S\+\)\s.*$/\1/g'
}

while uci delete network.@switch[-1] 2> /dev/null ;do continue ;done
switch=$( getSwitch )
uci get network.@switch[0] > /dev/null && exit 0
while uci delete network.@switch_vlan[-1] 2> /dev/null ;do continue ;done

uci -q batch << EOF

add network switch
set network.@switch[-1]=switch
set network.@switch[-1].name='$switch'
set network.@switch[-1].reset='1'
set network.@switch[-1].enable_vlan='0'

EOF

uci delete network.wan.device
uci delete network.wan6.device

uci commit network || exit 1
