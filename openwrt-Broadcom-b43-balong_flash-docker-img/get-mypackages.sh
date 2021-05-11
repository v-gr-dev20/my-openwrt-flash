# !/usr/bin/bash
# Скрипт извлекает готовые пакеты *.ipk из docker-образа.
# Скрипт находит Dockerfile в месте своего расположения, либо уровнем выше, и использует имя каталога в качестве имени образа контейнера.

function main()
{
	# Находим файлы docker
	local -a projectData
	readarray -t projectData < <( GetProject )
	local image="${projectData[0]}" projectPath="${projectData[1]}" DockerfileName="${projectData[2]}" DockerfilePath="${projectData[3]}"
	[ -z "$DockerfilePath" ] && { echo "Dockerfile not found." >&2; exit 1; }
	echo "${image}: ${DockerfilePath}"

	# Запускаем docker-контейнер
	#	здесь ожидаем получить готовые пакеты *.ipk
	outDirPath=${projectPath}/../target_dir
	mkdir -p "$outDirPath"
	docker run -it --rm \
		-v ${outDirPath}:/export ${image} \
		bash -c "cp -vfp /root/openwrt/bin/packages/mipsel_mips32/mypackages/*.ipk /export/ \
			"
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
		$commandName -h | --help
"
}

# Точка входа
typeset ThisScriptPath="$( readlink -m "$0" )"
if( echo "$1" |grep -E '^(-h|-help|--help)$' > /dev/null \
	|| [ 0 -ne $# ] )
then
	outputHelp
	exit
fi
# include
. "$( dirname "$ThisScriptPath" )/common.sh" 2> /dev/null || \
. "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" 2> /dev/null

main "$@"