#!/bin/sh

uci -q batch << EOF

# system.@system[0]=system
set system.@system[0].hostname='Mikrotik-hAPac3-EF1F'
set system.@system[0].zonename='Europe/Moscow'
set system.@system[0].timezone='MSK-3MSD,M3.5.0,M10.5.0/3'

EOF

uci commit system || exit 1
reboot
