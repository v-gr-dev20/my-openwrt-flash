#!/bin/sh

opkg update || exit 1
opkg install usb-modeswitch
opkg install kmod-usb-net kmod-usb-net-cdc-ether
opkg install kmod-usb-net-rndis
