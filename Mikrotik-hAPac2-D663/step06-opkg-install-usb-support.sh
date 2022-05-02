#!/bin/sh

opkg update || exit 1
opkg install usbutils usbreset
opkg install uhubctl hub-ctrl
