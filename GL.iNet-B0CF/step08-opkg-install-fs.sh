#!/bin/sh

opkg update || exit 1

opkg install e2fsprogs tune2fs fdisk gdisk
opkg install f2fs-tools
opkg install dosfstools
opkg install ntfs-3g-utils ntfs-3g
opkg install kmod-crypto-crc32
opkg install kmod-fs-f2fs
opkg install kmod-fs-vfat
opkg install kmod-fs-exfat
