# !/usr/bin/bash
# Скрипт извлекает из контейнера сборки openwrt расширенный набор opkg-пакетов и ключи, которыми подписаны пакеты

openwrtRootInContainer=/root
typeset -a itemsInContainer=(
	./openwrt/bin/targets/ar71xx/tiny/packages
	./openwrt/bin/packages/mips_24kc/base
	./openwrt/bin/packages/mips_24kc/luci
	./openwrt/bin/packages/mips_24kc/packages
	./openwrt/build_dir/target-mips_24kc_musl/root.orig-ar71xx/etc/opkg/keys
)
tarFile=openwrt-mips_24kc-export-packages.tgz

main() {
	# определяем параметры проекта (находим Dockerfile, получаем имя Docker-образа)
	local -a projectData
	readarray -t projectData < <( GetProject )
	local projectName=${projectData[0]}

	# определяем источник и цель
	local realTargetPath=${1:-.}
	local realTargetDir=
	local targetFile=
	[ -d "$realTargetPath" -o "/" == "${realTargetPath: -1}" ] && {
		realTargetDir=$( readlink -m "$realTargetPath" )
		realTargetPath=${realTargetDir}
	} || {
		realTargetPath=$( readlink -m "$realTargetPath" )
		realTargetDir=$( dirname "$realTargetPath" )
		targetFile=$( basename "$realTargetPath" )
	}
	[ ! -d "$realTargetDir" ] && {
		mkdir -p "${realTargetDir}"
	}
	local mappedTargetDir=/mnt/volatile-target-dir

	# копирование
	echo mount $realTargetDir '->' $mappedTargetDir
	docker run --rm -it -v ${realTargetDir}:${mappedTargetDir} "$projectName" bash -c \
		"tar -czf ${tarFile} -C ${openwrtRootInContainer} $( echo ${itemsInContainer[@]} ) && cp -v ${tarFile} ${mappedTargetDir}/${tarFile}"
}

# Выводит подсказку
function outputHelp()
{
	commandName=$( basename "$ThisScriptPath" )
	if [ ".sh" == ".${commandName##*.}" ] ;then
		commandName="${commandName%.*}"
	fi
	echo \
"	Usage:
		$commandName [ <destination> ]
		$commandName -h | --help
"
}

# Точка входа
typeset ThisScriptPath="$( readlink -m "$0" )"
if( echo "$1" |grep -E '\-h|\-\-help' > /dev/null );then
	outputHelp
	exit
fi
# include
i="$( dirname "$ThisScriptPath" )/common.sh" ;[ -f "$i" ] && . "$i"
i="$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" ;[ -f "$i" ] && . "$i"
echo "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" >&2

main "$@"