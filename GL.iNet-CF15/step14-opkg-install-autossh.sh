#!/bin/sh

opkg update || exit 1
opkg install autossh
