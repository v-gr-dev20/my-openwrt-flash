#!/bin/sh


getSwitch()
{
	swconfig list |sed 's/^\S\+\s\+\(\S\+\)\s.*$/\1/g'
}

switch=$( getSwitch )

uci get network.@switch[0] > /dev/null || exit 1
uci get network.@switch_vlan[5] > /dev/null && exit 0
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
set network.@switch_vlan[-1].ports='1 2 3 4 0t'

set network.@switch[0].enable_vlan='1'

EOF

i=0
while [ "device" == "$( uci get network.@device[$i] 2> /dev/null )" ]; do
	if [ "br-lan" == "$( uci get network.@device[$i].name 2> /dev/null )" ]; then
		uci delete network.@device[$i].ports
		uci add_list network.@device[$i].ports='eth0.5'
		break
	fi
	i=$(( i+1 ))
done

uci commit network || exit 1
