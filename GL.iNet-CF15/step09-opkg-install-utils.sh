#!/bin/sh

opkg update || exit 1
opkg install e2fsprogs tune2fs fdisk gdisk
opkg install swap-utils
opkg install lsof
opkg install usbutils usbreset uhubctl hub-ctrl
opkg install wget curl ca-bundle
opkg install nano mc tree screen
opkg install netperf speedtest-netperf
