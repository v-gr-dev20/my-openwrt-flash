# !Powershell
# Скрипт-обертка для запуска в Windows одноименного bash-скрипта в среде wsl2-debian.
# Скрипт определяет месторасположение целевого bash-скрипта непосредственно рядом с собственным месторасположением.

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	clear
	
	# Получаем путь и имя проекта - имя родительской папки скрипта на 2 уровня выше
	$thisScriptDirPath = $ThisScriptPath |Split-Path -parent
	$projectPath = $thisScriptDirPath |Split-Path -parent
	$projectName = $projectPath |Split-Path -Leaf
	<#assert#> if( [string]::IsNullOrEmpty( $projectName ) ) { throw }
	<#assert#> if( [string]::IsNullOrEmpty( $projectPath ) ) { throw }
	
	# Получаем источник точки монтирования проекта для системы сборки - родительский каталог проекта
	$projectParent = $projectPath |Split-Path -parent
	$projectMountPoint = convertPathToMountPoint $projectParent
	<#assert#> if( [string]::IsNullOrEmpty( $projectMountPoint ) ) { throw }

	# Получаем имя скрипта
	$thisScriptShortName = ( Get-ChildItem $ThisScriptPath ).Basename
	$thisScriptDirName = $thisScriptDirPath |Split-Path -Leaf

	# формируем строку с параметрами командной строки
	$paramsToString = ( convertToStringWithQuotas $commandLineArgs )
	
	# Запускаем систему сборки для проекта
	bash -c "'$( convertPathToMountPoint `"${thisScriptDirPath}`")/${thisScriptShortName}.sh' $paramsToString"
}

# Преобразует путь вида "C:\Parent\Dir\file" в "/mnt/c/Parent/Dir/file"
function convertPathToMountPoint( [Parameter( Position = 0 )][string] $path )
{
	$fullPath = $path |Resolve-Path
	$driveName = ( ( $fullPath |Split-Path -Qualifier ) -replace '\:$', '' ).ToLower()
	$atRootPath = ( $fullPath -replace '^.*\:', '' ) -replace '\\', '/'
	-join( "/mnt/", $driveName, $atRootPath )
}

# Преобразует массив строк вида @("w1 w2", "w3", "w4") в строку вида '"w1 w2" w3 w4'
function convertToStringWithQuotas( [Parameter( Position = 0 )][string[]] $items )
{
	$result = ""
	foreach( $item in $items ) {
		if( $item -match "\s" ) {
			$result = "${result} `\`"${item}`\`""
		} else {
			$result = "${result} ${item}"
		}
	}
	$result
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
main $Args