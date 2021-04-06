#!/bin/sh

opkg update || exit 1
opkg install luci luci-app-ddns luci-proto-3g
