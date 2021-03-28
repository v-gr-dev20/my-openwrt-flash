#!/bin/sh

uci -q batch << EOF

# network.lan=interface
set network.lan.ipaddr='192.168.20.1'

# system.@system[0]=system
set system.@system[0].hostname='TL-MR3420-FCB6'
set system.@system[0].zonename='Europe/Kiev'
set system.@system[0].timezone='EET-2EEST,M3.5.0/3,M10.5.0/4'

EOF

uci commit system || exit 1
uci commit network || exit 1
reboot
