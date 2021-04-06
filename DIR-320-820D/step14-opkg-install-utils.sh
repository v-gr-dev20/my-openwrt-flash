#!/bin/sh

opkg update || exit 1
opkg install usbutils usbreset hub-ctrl
opkg install wget curl ca-bundle
opkg install nano mc tree
opkg install netperf speedtest-netperf
