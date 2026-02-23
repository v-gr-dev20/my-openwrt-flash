#!/bin/bash

opkg update || exit 1
opkg install curl ca-bundle
opkg install ddns-scripts ddns-scripts-noip
opkg install luci-app-ddns
