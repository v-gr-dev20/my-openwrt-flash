#!/bin/sh

uci -q batch << EOF

set dropbear.main.GatewayPorts='on'
#delete dropbear.main.GatewayPorts

EOF

uci commit dropbear || exit 1
/etc/init.d/dropbear restart
