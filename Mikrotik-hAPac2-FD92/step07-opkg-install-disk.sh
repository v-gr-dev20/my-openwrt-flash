#!/bin/sh

opkg update || exit 1
opkg install kmod-fs-ext4 ubox block-mount kmod-scsi-core kmod-usb-storage
opkg install e2fsprogs fdisk