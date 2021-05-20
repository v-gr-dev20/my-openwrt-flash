#!/bin/sh

result=0

sed -i -e "/^#\s\{0,\}src\/gz\s\{1,\}openwrt_core\s/s:^#\s\{0,\}::" /etc/opkg/customfeeds.conf
grep -E '^src/gz\s+openwrt_core' /etc/opkg/customfeeds.conf > /dev/null || {
	echo src/gz openwrt_core file:///home/openwrt/bin/targets/brcm47xx/legacy/packages >> /etc/opkg/customfeeds.conf
}
sed -i -e "/^#\s\{0,\}src\/gz\s\{1,\}openwrt_base\s/s:^#\s\{0,\}::" /etc/opkg/customfeeds.conf
grep -E '^src/gz\s+openwrt_base' /etc/opkg/customfeeds.conf > /dev/null || {
	echo src/gz openwrt_base file:///home/openwrt/bin/packages/mipsel_mips32/base >> /etc/opkg/customfeeds.conf
}
cp /home/openwrt/build_dir/target-mipsel_mips32_musl/root.orig-brcm47xx/etc/opkg/keys/* /etc/opkg/keys

opkg update || exit 1
opkg install kmod-usb-net kmod-usb-net-cdc-ether || result=1
opkg install kmod-usb-net-rndis || result=1

sed -i -e "/^src\/gz\s\{1,\}openwrt_core\s/s::# \0:" /etc/opkg/customfeeds.conf
sed -i -e "/^src\/gz\s\{1,\}openwrt_base\s/s::# \0:" /etc/opkg/customfeeds.conf

opkg update

[ 0 -eq $result ] || exit 1
/etc/init.d/network restart