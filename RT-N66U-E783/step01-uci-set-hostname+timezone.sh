#!/bin/sh

uci -q batch << EOF

# system.@system[0]=system
set system.@system[0].hostname='RT-N66U-E783'
set system.@system[0].zonename='Europe/Moscow'
set system.@system[0].timezone='MSK-3'

EOF

uci commit system || exit 1
reboot
