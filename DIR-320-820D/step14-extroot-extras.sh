#!/bin/bash
# https://openwrt.org/docs/guide-user/additional-software/extroot_configuration

# Extras
# Preserving opkg lists
sed -i -e "/^lists_dir\s/s:/var/opkg-lists$:/usr/lib/opkg/lists:" /etc/opkg.conf
opkg update

# Add option force_space in /etc/opkg.conf to allow installation of packets bigger than your /rom partitions free space
grep -E '^option\s+force_space' /etc/opkg.conf > /dev/null || {
	echo option force_space >> /etc/opkg.conf
}
