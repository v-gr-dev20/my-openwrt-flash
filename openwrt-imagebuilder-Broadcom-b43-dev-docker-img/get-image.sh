# !/usr/bin/bash
# Скрипт извлекает из контейнера сборки openwrt готовый образ прошивки для WL-500gP-v2 / DIR-320

main() {
	# Находим файлы docker
	local -a projectData
	readarray -t projectData < <( GetProject )
	local projectName=${projectData[0]}
	local realTargetPath=$( readlink -m ${1:-.} )
	local mappedTargetPath=/target
	echo mount "$realTargetPath" '<-' $mappedTargetPath
	docker run --rm -it -v ${realTargetPath}:${mappedTargetPath} "$projectName" \
		cp -v \
		/root/openwrt/bin/targets/brcm47xx/legacy/openwrt-19.07.7-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx \
		$mappedTargetPath/
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
		$commandName
		$commandName <destination>
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