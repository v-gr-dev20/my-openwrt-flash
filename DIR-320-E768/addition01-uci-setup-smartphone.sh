#!/bin/sh

uci show network.hphone && exit 0

uci -q batch << EOF

set network.hphone=interface
set network.hphone.ifname='usb0'
set network.hphone.proto='dhcp'

# firewall.@zone[1]=zone
# firewall.@zone[1].name='wan'
add_list firewall.@zone[1].network='hphone'

EOF

uci commit network || exit 1
uci commit firewall || exit 1
/etc/init.d/network restart
/etc/init.d/firewall restart
