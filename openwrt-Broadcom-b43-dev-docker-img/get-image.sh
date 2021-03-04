# !/usr/bin/bash
# Скрипт извлекает из контейнера сборки openwrt готовый образ прошивки для WL-500gP-v2 / DIR-320

openwrtDirInContainer=/root/openwrt
sourceFileInContainer=${openwrtDirInContainer}/build_dir/target-mipsel_mips32_musl/openwrt-imagebuilder-brcm47xx-legacy.Linux-x86_64/bin/targets/brcm47xx/legacy/openwrt-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx

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
	docker run --rm -it -v ${realTargetDir}:${mappedTargetDir} "$projectName" \
		cp -v "$sourceFileInContainer" "${mappedTargetDir}/${targetFile}"
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