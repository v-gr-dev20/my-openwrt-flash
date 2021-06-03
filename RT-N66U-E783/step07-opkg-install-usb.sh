#!/bin/sh

opkg update || exit 1
opkg install kmod-usb2 kmod-usb-ehci kmod-usb-ohci
opkg install usbutils usbreset
