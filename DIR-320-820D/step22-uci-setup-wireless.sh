#!/bin/sh

wifi down

uci -q batch << EOF

wireless.radio0.channel='auto'
wireless.radio0.country='UA'

delete wireless.radio0.disabled
delete wireless.default_radio0.disabled
set wireless.default_radio0.key='password'\''s changed'
set wireless.default_radio0.encryption='psk2+tkip+ccmp'
set wireless.default_radio0.ssid='DIR320-820D'

EOF

uci commit wireless || exit 1

wifi up