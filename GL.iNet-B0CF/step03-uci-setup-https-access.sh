#!/bin/sh

uci -q batch << EOF

set uhttpd.main.redirect_https='1'

EOF

uci commit uhttpd || exit 1

i=0
while uci get firewall.@rule[$i] &> /dev/null ; do
	[ "Allow-HTTPS" == "$( uci get firewall.@rule[$i].name )" ] && exit 0
	i=$(( i+1 ));
done

uci -q batch << EOF

add firewall rule
set firewall.@rule[-1]=rule
set firewall.@rule[-1].dest_port='443'
set firewall.@rule[-1].src='wan'
set firewall.@rule[-1].target='ACCEPT'
set firewall.@rule[-1].name='Allow-HTTPS'

EOF

uci commit firewall || exit 1
/etc/init.d/firewall restart
