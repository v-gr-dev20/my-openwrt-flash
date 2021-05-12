# !/usr/bin/bash
# Скрипт запускает сборку проекта в docker-контейнере.
# Скрипт находит Dockerfile в месте своего расположения, либо уровнем выше, и использует имя каталога в качестве имени образа контейнера.
# Имя проекта должно передаваться единственным параметром.

function main()
{
	# Находим файлы docker
	local -a projectData
	readarray -t projectData < <( GetProject )
	local image="${projectData[0]}" projectPath="${projectData[1]}" DockerfileName="${projectData[2]}" DockerfilePath="${projectData[3]}"
	[ -z "$DockerfilePath" ] && { echo "Dockerfile not found." >&2; exit 1; }
	echo "${image}: ${DockerfilePath}"

	# Запускаем сборку проекта в docker-контейнере
	project=$1
	[ -z "$project" ] && { echo "Project not found." >&2; exit 1; }
	# исходники кладем выше-выше
	projectSrcPath=${projectPath}/../../${project}
	# сюда попадет готовый пакет *.ipk
	outDirPath=${projectPath}/../target_dir
	projectDir=$( basename "${projectPath}" )
	mkdir -p "$outDirPath"
	docker run -it --rm \
		-v ${projectSrcPath}:/root/${project}:ro \
		-v ${projectPath}:/root/${projectDir}:ro \
		-v ${outDirPath}:/export ${image} \
		bash -c "cp -f /root/${projectDir}/openwrt/feeds.conf . \
			  && rm -rf /root/mypackages && cp -rf /root/${projectDir}/mypackages /root/ \
			  && ./scripts/feeds update -a \
			  && ./scripts/feeds install -a \
			  && make defconfig \
			  && make package/${project}/clean \
			  && make package/${project}/compile \
			  && cp -vfp /root/openwrt/bin/packages/mipsel_mips32/mypackages/*.ipk /export/ \
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
		$commandName projectName
		$commandName -h | --help
"
}

# Точка входа
typeset ThisScriptPath="$( readlink -m "$0" )"
if( echo "$1" |grep -E '^(-h|-help|--help)$' > /dev/null \
	|| [ 1 -ne $# ] )
then
	outputHelp
	exit
fi
# include
. "$( dirname "$ThisScriptPath" )/common.sh" 2> /dev/null || \
. "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" 2> /dev/null

main "$@"