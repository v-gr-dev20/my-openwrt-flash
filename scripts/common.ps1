# !Powershell
# Общие фукции
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )

# Считывает параметры программы из файла config.json
function getConfig( [Parameter( Position = 0 )][string] $projectName )
{
	$projectPath = getProject( $projectName )
	$result = Get-Content "$projectPath/config.json" |ConvertFrom-Json -AsHashtable
	$result.projectName = $projectName
	$result
}

# Возвращает путь проекта
function getProject( [Parameter( Position = 0 )][string] $projectName )
{
	$thisScriptDirPath = $ThisScriptPath |Split-Path -parent
	$projectPath = Join-Path -Path ( $thisScriptDirPath |Split-Path -parent ) -ChildPath $projectName
	<#assert#> if( [string]::IsNullOrEmpty( $projectName ) ) { throw }
	<#assert#> if( [string]::IsNullOrEmpty( $projectPath ) ) { throw }

	$projectPath
}

