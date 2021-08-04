#!/bin/bash
# Скрипт выполняет перенос системных разделов на указанный диск
# Для реального запуска необходимо удалить/закомментировать следующую строку
echo 'Remove/comment the protective line' && exit 1

execMode=1
targetDev=/dev/sdc

# Выполняет командную строку в установленном режиме исполнения
execEx()
{
	cmd="$*"
	# все режимы выполнения -
	#	0:exec	-> только выполнение,
	#	1:debug	-> exec+echo,
	#	2:echo	-> вывод командной строки без выполнения,
	#	3:nop	-> без выполнения, без вывода.
	set -- exec debug echo nop
	local execModeName="$( eval echo -n '$'$(( execMode+1 )) )"
	[ "$execModeName" ] || execModeName=$4
	case "$execModeName" in
		exec) $cmd ;;
		debug) echo '#' $cmd; $cmd ;;
		echo) echo '>' $cmd ;;
		nop) ;;
		*) echo execEx assert error >&2; exit 1;;
	esac
}

core=/rwm
coreConfig="${core}/upper/etc/config"
targetConfig=
sourceDev="$( awk -e '/\s\/overlay\s/{print $1}' /etc/mtab )"

[ -n "$sourceDev" -a -n "$targetDev" ] || { 
	echo Assert: source and target exist
	exit 1
}

# copy /home
DEVICE="${targetDev}4"
mountPoint=/tmp/mnt/$( basename "${DEVICE}" )
mkdir -p "${mountPoint}"
execEx mount -text4 "${DEVICE}" "${mountPoint}" && {
	execEx cp -a -f /home/. "${mountPoint}" || exit 1
	execEx umount "${mountPoint}" && rmdir "${mountPoint}"
}

# copy /overlay
DEVICE="${targetDev}3"
mountPoint=/tmp/mnt/$( basename "${DEVICE}" )
mkdir -p "${mountPoint}"
execEx mount -text4 "${DEVICE}" "${mountPoint}" && {
	execEx cp -a -f /overlay/. "${mountPoint}" || exit 1
	targetConfig="${mountPoint}/upper/etc/config"
}

[ -d "$targetConfig" ] || {
	echo Target config not available
	exit 1
}

# move /overlay
DEVICE="${targetDev}3"
unset UUID
eval $( block info "${DEVICE}" | grep -o -e "UUID=\S*" )
[ -n "$UUID" ] && {
	execEx uci -c "${targetConfig}" set fstab.overlay.uuid="$UUID"
}

# move /home
DEVICE="${targetDev}4"
unset UUID uciMountpoint
eval $( block info "${DEVICE}" | grep -o -e "UUID=\S*" )
[ -n "$UUID" ] && {
	uciMountpoint=$( uci show fstab |grep "target='/home'" |sed 's/^fstab\.\(.\+\)\.target=.*/\1/' )
	[ -n "$uciMountpoint" ] && {
		execEx uci -c "${targetConfig}" set fstab.${uciMountpoint}.uuid="$UUID"
	}
}

execEx uci -c "${targetConfig}" commit fstab
execEx cp -a -f "${targetConfig}/fstab" "${coreConfig}/fstab"
execEx umount $( df "${targetConfig}" |sed 1d |cut -f1 -d' ' )

echo Done.
execEx reboot
