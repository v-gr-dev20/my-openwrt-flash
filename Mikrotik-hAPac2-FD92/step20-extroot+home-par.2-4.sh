#!/bin/bash
# https://openwrt.org/ru/docs/guide-user/additional-software/extroot_configuration

targetDev=/dev/sda

uci set fstab.@global[0].delay_root='15'

# https: paragraph 2
#DEVICE="/dev/mtdblock3"
#DEVICE="/dev/mtdblock5"
#DEVICE="/dev/mtdblock8"
DEVICE="$( awk -e '/\s\/overlay\s/{print $1}' /etc/mtab )"
uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${DEVICE}"
uci set fstab.rwm.target="/rwm"

# https: paragraph 3
uci -q delete fstab.overlay
DEVICE="${targetDev}3"
unset UUID uciMountpoint
eval $( block info "${DEVICE}" | grep -o -e "UUID=\S*" )
[ -n "$UUID" ] && uciMountpoint=$( uci show fstab |grep $UUID |sed 's/^fstab\.\(.\+\)\.uuid=.*/\1/' )
[ -n "$uciMountpoint" ] && uci -q delete fstab.${uciMountpoint}
uci set fstab.overlay="mount"
uci set fstab.overlay.target="/overlay"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.enabled_fsck='1'

# mount /home
DEVICE="${targetDev}4"
unset UUID uciMountpoint
eval $( block info "${DEVICE}" | grep -o -e "UUID=\S*" )
[ -n "$UUID" ] && uciMountpoint=$( uci show fstab |grep $UUID |sed 's/^fstab\.\(.\+\)\.uuid=.*/\1/' )
[ -n "$uciMountpoint" ] && {
	uci set fstab.${uciMountpoint}.target="/home"
	uci set fstab.${uciMountpoint}.enabled='1'
	uci set fstab.${uciMountpoint}.enabled_fsck='1'
}

# mount /home/backup
DEVICE="/dev/sdb1"
unset UUID uciMountpoint
eval $( block info "${DEVICE}" | grep -o -e "UUID=\S*" )
[ -n "$UUID" ] && uciMountpoint=$( uci show fstab |grep $UUID |sed 's/^fstab\.\(.\+\)\.uuid=.*/\1/' )
[ -n "$uciMountpoint" ] && {
	uci set fstab.${uciMountpoint}.target="/home/backup"
	uci set fstab.${uciMountpoint}.enabled='1'
	uci set fstab.${uciMountpoint}.enabled_fsck='1'
}

uci commit fstab

# https: paragraph 4
DEVICE="${targetDev}3"
mountPoint=/tmp/mnt/$( basename "${DEVICE}" )
mkdir -p "${mountPoint}"
mount "${DEVICE}" "${mountPoint}"
cp -a -f /overlay/. "${mountPoint}"
umount "${mountPoint}" && rmdir "${mountPoint}"

reboot
