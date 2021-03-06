# !Powershell
# Общие фукции
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )

# Считывает параметры программы из файла config.json
function getConfig( [Parameter( Position = 0 )][string] $projectName )
{
	$projectPath = getProject( $projectName )
	$result = Get-Content "$projectPath/config.json" |ConvertFrom-Json -AsHashtable
	# вызов без параметров - считаем папку скрипта папкой проекта
	if( [string]::IsNullOrEmpty( $projectName ) ) {
		$projectName = $ThisScriptPath |Split-Path -parent |Split-Path -leaf
	}
	$result.projectName = $projectName
	$result
}

# Возвращает путь проекта
function getProject( [Parameter( Position = 0 )][string] $projectName )
{
	$thisScriptDirPath = $ThisScriptPath |Split-Path -parent
	# вызов без параметров - считаем папку скрипта папкой проекта
	if( [string]::IsNullOrEmpty( $projectName ) ) {
		$projectPath = $thisScriptDirPath
	} else {
		$projectPath = Join-Path -Path ( $thisScriptDirPath |Split-Path -parent ) -ChildPath $projectName
	}
	<#assert#> if( [string]::IsNullOrEmpty( $projectPath ) ) { throw }

	$projectPath
}

# Копирует hashtable в части указанного набора ключей
function Select-Hashtable-by-Keys( [Parameter( Position = 0 )][hashtable] $map, [Parameter( Position = 1 )][string[]] $keys )
{
	$result = @{}
	# получаем срез конфига по следующим требуемым полям
	$keys |ForEach-Object {
		if( $PSItem -in $map.Keys ) {
			$result[$PSItem] = $config[$PSItem]
		}
	}
	$result
}
