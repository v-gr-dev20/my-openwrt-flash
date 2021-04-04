#!/bin/sh

sed -i -e "/^#\s\{0,\}src\/gz\s\{1,\}openwrt_core\s/s:^#\s\{0,\}::" /etc/opkg/customfeeds.conf
grep -E '^src/gz\s+openwrt_core' /etc/opkg/customfeeds.conf > /dev/null || {
	echo src/gz openwrt_core file:///home/openwrt/bin/targets/ar71xx/tiny/packages >> /etc/opkg/customfeeds.conf
}
sed -i -e "/^#\s\{0,\}src\/gz\s\{1,\}openwrt_base\s/s:^#\s\{0,\}::" /etc/opkg/customfeeds.conf
grep -E '^src/gz\s+openwrt_base' /etc/opkg/customfeeds.conf > /dev/null || {
	echo src/gz openwrt_base file:///home/openwrt/bin/packages/mips_24kc/base >> /etc/opkg/customfeeds.conf
}
cp /home/openwrt/build_dir/target-mips_24kc_musl/root.orig-ar71xx/etc/opkg/keys/* /etc/opkg/keys

opkg update || exit 1
opkg --force-depends install kmod-ath kmod-ath9k-common kmod-ath9k || exit 1

sed -i -e "/^src\/gz\s\{1,\}openwrt_core\s/s::# \0:" /etc/opkg/customfeeds.conf
sed -i -e "/^src\/gz\s\{1,\}openwrt_base\s/s::# \0:" /etc/opkg/customfeeds.conf

opkg update || exit 1
opkg install wpad-mini || exit 1

reboot
