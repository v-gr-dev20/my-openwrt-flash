#!/bin/sh
# Скипт переопределит mac-адреса портов свича в соответствии с vlanID
. /lib/functions.sh

uci get network.@switch[0] > /dev/null || exit 1
uci get network.@switch_vlan[0] > /dev/null || exit 1

getSwitch()
{
	swconfig list |sed 's/^\S\+\s\+\(\S\+\)\s.*$/\1/g'
}

getBridge()
{
	echo eth0
}

getMac()
{
	local dev=$1
	local mac=$( ip link show ${dev} |sed -n '/link\/ether/s/^.*link\/ether\s*\(\S\+\).*$/\1/p' |head -1 )
	echo $mac
}

incrementMacaddrFF()
{
	local baseMac=$1
	local increment=${2:-1}
	[ -n "$baseMac" ] || return 1

	local lastOctet=$( echo ${baseMac} |sed 's/^.*\(..\)\s*$/\1/' )
	local lastOctetDec=$( printf '%d' "0x${lastOctet}" )
	local newOctetDec=$( expr ${lastOctetDec} + "${increment}" )
	local newOctet=$( printf '%02X' ${newOctetDec} )
	local newMac="$( echo ${baseMac} |sed 's/..$//' )${newOctet}"
	echo $newMac
}

handle_switch_vlan()
{
	local bridgeName=$( getBridge )
	local vlanID
	local switchName
	config_get switchName "$1" 'device'
	config_get vlanID "$1" 'vlan'
	[ -n "$switchName" -a -n "$vlanID" ] || return 1

	local vlanDevice=${bridgeName}$( echo $vlanID |sed 's/^0\+//g' | sed 's/^./\.&/' )
	local vlanMac=$( incrementMacaddrFF $( getMac $bridgeName ) $vlanID )

	[ 0 -eq $vlanID ] && return

	echo '
		add network device
		set network.@device[-1]=device
		set network.@device[-1].name='$vlanDevice'
		set network.@device[-1].macaddr='$vlanMac
}

clean()
{
	local bridgeName=$( getBridge )
	local i=0
	while [ "device" == "$( uci get network.@device[$i] 2> /dev/null )" ]; do
		if [ "$bridgeName" == "$( uci get network.@device[$i].name |sed 's/\..*$//' )" ]; then
			uci delete network.@device[$i]
		else
			i=$(( i+1 ))
		fi
	done
}

########### Точка входа ###########

clean

config_load network

uci -q batch << EOF
$( config_foreach handle_switch_vlan switch_vlan )
EOF

uci commit network || exit 1
/etc/init.d/network restart
