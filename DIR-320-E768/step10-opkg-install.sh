#!/bin/ash
# Скрипт инсталлирует менеджер пакетов opkg

installPackageToTmp()
{
	local packageName="$1"
	[ -n "${packageName}" ] || { echo "Error: Empty package name" >&2; return 1; }
	local installTargetDir=/tmp
	local packagePath="$( ls /tmp/${packageName}*.ipk 2>/dev/null |sed '/^\s*$/d' |sed '1!d' )"
	[ -f "$packagePath" ] || { echo "Error: Package ${packageName} not found" >&2; return 1; }
	packageSpec=$( basename "${packagePath}" |sed 's/\.ipk$//' )
	[ -n "$packageSpec" ] || { echo "Error: Wrong package name" >&2; return 1; }
	local packageUnpackDir=/tmp/${packageSpec}
	mkdir -p "${packageUnpackDir}" || { echo "Error: Disk write failed" >&2; return 2; }
	tar -C "${packageUnpackDir}" -xzf "${packagePath}" || { echo "Error: Failed to unpack package" >&2; return 2; }
	tar -C "${installTargetDir}" -xzf "${packageUnpackDir}/data.tar.gz" || { echo "Error: Failed to unpack package" >&2; return 2; }
	rm -rf "${packageUnpackDir}"
	return 0
}

installPackagesToTmp()
{
	while read packageName; do
		installPackageToTmp "$packageName"
		local ret=$?
		[ 0 -eq $ret ] || return $ret
	done
	return 0
}
######## Точка входа ########

# Устанавливаем opkg и необходимые библиотеки временно в /tmp
# Ожидаем заранее залитые необходимые пакеты /tmp/*.ipk
installPackagesToTmp <<END
libuclient
uclient-fetch
opkg
END

[ 0 -eq $? ] || { echo "Failed to install packages"; exit 1; }
echo "All packages was installed successfully into /tmp"

# Устанавливаем постоянный opkg в / (корневую директорию)
PATH=/tmp/bin:/tmp/usr/sbin${PATH:+:$PATH} LD_LIBRARY_PATH=/tmp/lib:/tmp/usr/lib:/lib:/usr/lib /tmp/bin/opkg --dest root -o / --conf /tmp/etc/opkg.conf install /tmp/libuclient*.ipk
PATH=/tmp/bin:/tmp/usr/sbin${PATH:+:$PATH} LD_LIBRARY_PATH=/tmp/lib:/tmp/usr/lib:/lib:/usr/lib /tmp/bin/opkg --dest root -o / --conf /tmp/etc/opkg.conf install /tmp/uclient-fetch*.ipk
PATH=/tmp/bin:/tmp/usr/sbin${PATH:+:$PATH} LD_LIBRARY_PATH=/tmp/lib:/tmp/usr/lib:/lib:/usr/lib /tmp/bin/opkg --dest root -o / --conf /tmp/etc/opkg.conf install /tmp/opkg*.ipk
opkg update

[ 0 -eq $? ] ||  { echo "opkg installation failed" >&2; exit 1; }

