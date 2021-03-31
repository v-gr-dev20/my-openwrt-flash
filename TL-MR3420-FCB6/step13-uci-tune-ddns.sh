#!/bin/sh

uci -q batch << EOF

set ddns.myddns_ipv4.use_https='1'

EOF

uci commit ddns || exit 1
/etc/init.d/ddns enable
/etc/init.d/ddns restart
