#!/bin/sh

uci -q batch << EOF

set network.lan.dns='192.168.2.1'

add network route
set network.@route[-1]=route
set network.@route[-1].interface='lan'
set network.@route[-1].target='0.0.0.0'
set network.@route[-1].netmask='0.0.0.0'
set network.@route[-1].gateway='192.168.19.2'
set network.@route[-1].metric='100'

EOF

uci commit network || exit 1
/etc/init.d/network restart