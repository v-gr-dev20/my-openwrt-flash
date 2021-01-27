# !/usr/bin/bash
# Скрипт запускает сборку docker-образа из Dockerfile.
# Скрипт находит Dockerfile по параметру в командной строке.
# Если параметров нет, то скрипт находит Dockerfile в текущей или родительской папке уровнем выше.

function main()
{
	local projectName projectPath DockerfileName DockerfilePath
	# Находим файлы docker
	GetProject $1 |{ read projectName; read projectPath; read DockerfileName; read DockerfilePath; }

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
if( [ -z "$1" ] || echo "$1" |grep -E '\-h|\-help' > /dev/null );then
	outputHelp
	exit
fi
# include
. "$( dirname "$ThisScriptPath" )/common.sh" 2> /dev/null || \
. "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" 2> /dev/null

main "$@"