# !Powershell
# Скрипт сохраняет файлы конфигурации openwrt/uci из удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	getFile
}

. "./common.ps1"

# Сохраняет файл конфигурации openwrt/uci
function getFile()
{
	$deviceURN = $config.user + "@" + $config.server
	$deviceName = $config.device
	$projectName, $projectPath = getProjectNP
	ssh $deviceURN "uci show" > "$projectPath/${deviceName}-uci"
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
$config = getConfig
if( 0 -lt $Args.Count ) {
	outputHelp
	exit
}
main $Args