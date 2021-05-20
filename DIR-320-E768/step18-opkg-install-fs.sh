#!/bin/sh

opkg update || exit 1

opkg install e2fsprogs tune2fs fdisk gdisk
opkg install f2fs-tools
opkg install dosfstools
opkg install ntfs-3g-utils ntfs-3g

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
opkg install kmod-crypto-crc32
opkg install kmod-fs-f2fs
opkg install kmod-fs-vfat
opkg install kmod-fs-exfat

sed -i -e "/^src\/gz\s\{1,\}openwrt_core\s/s::# \0:" /etc/opkg/customfeeds.conf
sed -i -e "/^src\/gz\s\{1,\}openwrt_base\s/s::# \0:" /etc/opkg/customfeeds.conf

opkg update || exit 1
