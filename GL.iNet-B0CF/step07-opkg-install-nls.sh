#!/bin/sh

opkg update || exit 1
opkg install kmod-nls-cp1251 kmod-nls-cp866 kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8
