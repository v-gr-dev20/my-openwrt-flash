#!/bin/sh
# Скрипт переопределит mac-адреса портов свича (DSA)

getBridge()
{
	echo br-lan
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

getPorts()
{
	local bridgeName=$( getBridge )
	local i=0
	while [ "device" == "$( uci get network.@device[$i] 2> /dev/null )" ]; do
		if [ "$bridgeName" == "$( uci get network.@device[$i].name 2> /dev/null )" ]; then
			uci get network.@device[$i].ports 2> /dev/null
			return
		fi
		i=$(( i+1 ))
	done
}

handle_port()
{
	local port=$1
	local portIndex=$2
	local bridgeName=$( getBridge )
	local increment=$(( portIndex + 2 ))
	local portMac=$( incrementMacaddrFF $( getMac $bridgeName ) $increment )

	echo '
		add network device
		set network.@device[-1]=device
		set network.@device[-1].name='$port'
		set network.@device[-1].macaddr='$portMac
}

clean()
{
	local bridgeName=$( getBridge )
	local i=0
	while [ "device" == "$( uci get network.@device[$i] 2> /dev/null )" ]; do
		local devName=$( uci get network.@device[$i].name 2> /dev/null )
		if [ "$bridgeName" != "$devName" ] && echo "$devName" | grep -q '^lan[0-9]'; then
			uci delete network.@device[$i]
		else
			i=$(( i+1 ))
		fi
	done
}

########### Точка входа ###########

clean

bridgeName=$( getBridge )
ports=$( getPorts )
[ -n "$ports" ] || exit 1

portIndex=1
batchCmds=""
for port in $ports; do
	batchCmds="$batchCmds
$( handle_port $port $portIndex )"
	portIndex=$(( portIndex+1 ))
done

uci -q batch << EOF
$batchCmds
EOF

uci commit network || exit 1
/etc/init.d/network restart
