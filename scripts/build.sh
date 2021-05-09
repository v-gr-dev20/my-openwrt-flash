# !/usr/bin/bash
# Скрипт запускает сборку docker-образа из Dockerfile.
# Скрипт находит Dockerfile по параметру в командной строке.
# Если параметров нет, то скрипт находит Dockerfile в текущей или родительской папке уровнем выше.

function main()
{
	# Находим файлы docker
	local -a projectData
	readarray -t projectData < <( GetProject "$1" )
	local projectName="${projectData[0]}" projectPath="${projectData[1]}" DockerfileName="${projectData[2]}" DockerfilePath="${projectData[3]}"
	[ -n "$DockerfilePath" ] && { 
		echo "${projectName}: ${DockerfilePath}"

		# Запускаем сборку docker-образа
		docker build ${projectName:+-t "$projectName"} -f  "$projectPath/$DockerfileName" "$projectPath"
	} || {
		echo "Dockerfile not found." >&2
	}
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
		$commandName dockerImageName | dockerImagePath
		$commandName -h | --help
"
}

# Точка входа
typeset ThisScriptPath="$( readlink -m "$0" )"
if( echo "$1" |grep -E '^(-h|-help|--help)$' > /dev/null );then
	outputHelp
	exit
fi
# include
. "$( dirname "$ThisScriptPath" )/common.sh" 2> /dev/null || \
. "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" 2> /dev/null

main "$@"