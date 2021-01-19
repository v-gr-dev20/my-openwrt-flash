# !Powershell
# Скрипт перезапускает сетевые подключения на удаленном устройстве через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	restartNetwork
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )

# Выполняет рестарт сети на хосте
function restartNetwork()
{
	$deviceURN = $config.user + "@" + $config.server
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
		$commandName <device>
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 1 -lt $Args.Count -or 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
$config = getConfig $Args[0]
main( $Args | Select-Object -Skip 1 )