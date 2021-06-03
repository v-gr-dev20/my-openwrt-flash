#!/bin/sh

opkg update || exit 1
opkg install asterisk asterisk-pjsip asterisk-app-stack
opkg install asterisk-cdr asterisk-cdr-csv
opkg install asterisk-pbx-spool
opkg install asterisk-func-dialplan

opkg install asterisk-codec-alaw asterisk-codec-ulaw asterisk-codec-g722 asterisk-codec-g726 asterisk-codec-g729 asterisk-codec-gsm
opkg install asterisk-codec-adpcm
opkg install asterisk-codec-opus

opkg install asterisk-format-g719
opkg install asterisk-format-g723
opkg install asterisk-format-g726
opkg install asterisk-format-g729
opkg install asterisk-format-gsm 
opkg install asterisk-format-h263
opkg install asterisk-format-h264
opkg install asterisk-format-pcm 
opkg install asterisk-format-wav 
opkg install asterisk-format-wav-gsm

opkg install asterisk-bridge-builtin-features
opkg install asterisk-bridge-builtin-interval-features
opkg install asterisk-bridge-holding
opkg install asterisk-bridge-native-rtp
opkg install asterisk-bridge-simple
opkg install asterisk-bridge-softmix

opkg install asterisk-chan-bridge-media
opkg install asterisk-chan-iax2
opkg install asterisk-chan-rtp

opkg install asterisk-res-rtp-asterisk
opkg install asterisk-res-rtp-multicast
opkg install asterisk-res-srtp

opkg install asterisk-sounds
