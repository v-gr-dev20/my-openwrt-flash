#!/bin/sh

opkg update || exit 1
opkg install usbutils
opkg install uhubctl hub-ctrl
