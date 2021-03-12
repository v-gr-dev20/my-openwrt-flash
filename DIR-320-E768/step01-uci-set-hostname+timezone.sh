#!/bin/sh

uci -q batch << EOF

# system.@system[0]=system
set system.@system[0].hostname='DIR320-E768'
set system.@system[0].zonename='Europe/Moscow'
set system.@system[0].timezone='MSK-3'

EOF

uci commit system || exit 1
reboot
