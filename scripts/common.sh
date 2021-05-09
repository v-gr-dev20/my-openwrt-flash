# !/usr/bin/bash

# Находит Dockerfile в текущей или родительской папке уровнем выше.
# Возвращает строки (в stdout)
#	1 - имя проекта (docker-образа)
#	2 - полный путь к папке с <Dockerfile>
#	3 - имя файла <Dockerfile>
#	4 - полный путь к <Dockerfile>
# На входе:
#	$1	- один из вариантов
#		- пусто
#		- путь к папке или файлу <Dockerfile>
#		- ключевое имя для поиска файла или папки с <Dockerfile>
function GetProject()
{
	# строки результата
	local -a result
	# этот суффикс будет добавлен при поиске к вариантам пути Dockerfile
	local suffix=-docker-img
	# упорядоченный список путей поиска Dockerfile
	local -a searchPlan
	# путь к Dockerfile
	local projectPath=
	# имя docker-образа
	local projectName=
	# имя Dockerfile
	local DockerfileName=

	# Формируем план поиска Dockerfile
	if [ -z "$1" ] ;then
		searchPlan=( "${searchPlan[@]}" "$( pwd )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "${searchPlan[-1]}" )" )
	elif [[ "$1" == "$( basename "$1" )" && ! $1 =~ ^(\.|\.\.|\/)$ ]] ;then
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "$1" )" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( pwd )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )/$1" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "${searchPlan[-1]}" )/$1" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( dirname "$( readlink -m "$0" )" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "../$1" )" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		projectName=$1
	elif [[ "$1" == "$( readlink -m "$1" )" ]] ;then
		searchPlan=( "${searchPlan[@]}" "$1" )
	else
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "$1" )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )/$1" )
	fi

	# Находим Dockerfile проекта
	result=( "${result[@]}" "" )
	for projectPath in "${searchPlan[@]}" ;do
		[ -f "$projectPath" ] && {
			result[-1]="$projectPath"
			break
		}
		[[ -d "$projectPath" && -f "$projectPath/Dockerfile" ]] && {
			result[-1]="$projectPath/Dockerfile"
			break
		}
	done

	# Получаем имя docker-образа
	projectName=${projectName:-$( echo "${result[-1]}" |sed 's/^\///' )}
	if [ "$( basename "$projectName" )" == "Dockerfile" ] ;then
		projectName=$( dirname "$projectName" )
	fi
	projectName=$( basename "$projectName" |sed 's/\('${suffix}'\)\{1,\}$//g' |sed 's/^[\.\/]$//g' |tr '[:upper:]' '[:lower:]' )

	# выдаем строки результата
	result=( "$projectName" "$( dirname "${result[-1]}" )" "$( basename "${result[-1]}" )" "${result[@]}" )
	for item in "${result[@]}" ;do
		echo "$item"
	done
}