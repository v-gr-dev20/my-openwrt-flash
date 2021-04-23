# !/usr/bin/bash
# Скрипт извлекает из контейнера сборки openwrt готовый образ прошивки для TL-MR3420-v1 и манифест

openwrtDirInContainer=/root/openwrt
typeset -a sourceFilesInContainer=(
	"${openwrtDirInContainer}/build_dir/target-mips_24kc_musl/openwrt-imagebuilder-ar71xx-tiny.Linux-x86_64/bin/targets/ar71xx/tiny/openwrt-ar71xx-tiny-tl-mr3420-v1-squashfs-sysupgrade.bin"
	"${openwrtDirInContainer}/build_dir/target-mips_24kc_musl/openwrt-imagebuilder-ar71xx-tiny.Linux-x86_64/bin/targets/ar71xx/tiny/openwrt-ar71xx-tiny-device-tl-mr3420-v1.manifest"
)

main() {
	# определяем параметры проекта (находим Dockerfile, получаем имя Docker-образа)
	local -a projectData
	readarray -t projectData < <( GetProject )
	local projectName=${projectData[0]}

	# определяем источник и цель
	local realTargetPath=${1:-.}
	local realTargetDir=
	[ -d "$realTargetPath" -o "/" == "${realTargetPath: -1}" ] && {
		realTargetDir=$( readlink -m "$realTargetPath" )
		realTargetPath=${realTargetDir}
	} || {
		realTargetPath=$( readlink -m "$realTargetPath" )
		realTargetDir=$( dirname "$realTargetPath" )
	}
	[ ! -d "$realTargetDir" ] && {
		mkdir -p "${realTargetDir}"
	}
	local mappedTargetDir=/mnt/volatile-target-dir

	# копирование
	echo mount $realTargetDir '->' $mappedTargetDir
	docker run --rm -it -v ${realTargetDir}:${mappedTargetDir} "$projectName" \
		cp -v "${sourceFilesInContainer[@]}" "${mappedTargetDir}/"
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