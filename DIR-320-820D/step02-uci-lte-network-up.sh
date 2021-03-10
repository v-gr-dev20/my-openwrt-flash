#!/bin/sh

uci -q batch << EOF

set network.lte=interface
set network.lte.ifname='eth1'
set network.lte.proto='dhcp'

# firewall.@zone[1]=zone
# firewall.@zone[1].name='wan'
add_list firewall.@zone[1].network='lte'

EOF

uci commit network || exit 1
uci commit firewall || exit 1
reboot
