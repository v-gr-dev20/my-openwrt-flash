#!/bin/sh

uci -q batch << EOF

set ddns.myddns_ipv4.lookup_host='grigorovich-fam.ddns.net'
set ddns.myddns_ipv4.domain='grigorovich-fam.ddns.net'
set ddns.myddns_ipv4.username='grigorovich-fam'
set ddns.myddns_ipv4.password='password'\''s changed'
set ddns.myddns_ipv4.interface='lte'
set ddns.myddns_ipv4.ip_source='web'
set ddns.myddns_ipv4.service_name='no-ip.com'
set ddns.myddns_ipv4.enabled='1'
set ddns.myddns_ipv4.use_https='0'

set ddns.myddns_ipv6.enabled='0'

EOF

uci commit ddns || exit 1
/etc/init.d/ddns enable
/etc/init.d/ddns restart
