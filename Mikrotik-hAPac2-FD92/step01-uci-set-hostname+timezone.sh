#!/bin/sh

uci -q batch << EOF

# system.@system[0]=system
set system.@system[0].hostname='Mikrotik-hAPac2-FD92'
set system.@system[0].zonename='Europe/Kiev'
set system.@system[0].timezone='EET-2EEST,M3.5.0/3,M10.5.0/4'

EOF

uci commit system || exit 1
reboot
