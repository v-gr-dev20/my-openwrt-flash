#!/bin/sh

uci show network.wan || exit 1

uci -q batch << EOF

set network.wan=interface
set network.wan.ifname='eth1'
set network.wan.proto='pppoe'
set network.wan.username='1978'
set network.wan.password='password'\''s changed'
set network.wan.ipv6='auto'

EOF

uci commit network || exit 1
/etc/init.d/network restart