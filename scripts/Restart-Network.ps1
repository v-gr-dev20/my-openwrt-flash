# !Powershell
# Скрипт перезапускает сетевые подключения на удаленном устройстве через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	restartNetwork
}

# Общие функции
. "$( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )"

# Выполняет рестарт сети на хосте
function restartNetwork()
{
	$deviceURN = $config.user + "@" + $config.server
	$deviceName = $config.device
	$projectName, $projectPath = getProjectNP
	ssh $deviceURN "(( /etc/init.d/network restart ;sleep 10 ;if ! ping -w1 8.8.8.8 > /dev/null ;then reboot ;fi )&)&"
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