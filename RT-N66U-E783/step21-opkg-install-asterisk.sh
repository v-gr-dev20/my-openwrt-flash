#!/bin/sh

opkg update || exit 1
opkg install asterisk16 asterisk16-pjsip asterisk16-chan-sip
opkg install asterisk16-codec-alaw asterisk16-codec-ulaw asterisk16-codec-g722 asterisk16-codec-g726 asterisk16-codec-g729 asterisk16-codec-gsm
opkg install asterisk16-codec-adpcm
opkg install asterisk16-codec-opus
opkg install asterisk16-format-g719
opkg install asterisk16-format-g723
opkg install asterisk16-format-g726
opkg install asterisk16-format-g729
opkg install asterisk16-format-gsm 
opkg install asterisk16-format-h263
opkg install asterisk16-format-h264
opkg install asterisk16-format-pcm 
opkg install asterisk16-format-wav 
opkg install asterisk16-format-wav-gsm
opkg install asterisk16-bridge-native-rtp
opkg install asterisk16-chan-rtp
opkg install asterisk16-res-rtp-asterisk
opkg install asterisk16-res-rtp-multicast
opkg install asterisk16-res-srtp
opkg install asterisk16-res-ari-sounds
opkg install asterisk16-sounds
