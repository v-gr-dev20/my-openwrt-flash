#!/bin/sh

opkg update || exit 1
opkg install usbutils
opkg install wget curl ca-bundle
opkg install nano mc
opkg install netperf speedtest-netperf
