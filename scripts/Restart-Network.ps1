# !Powershell
# Скрипт перезапускает сетевые подключения на удаленном устройстве через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	restartNetwork $anURNpartOfConfig
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выполняет рестарт сети на хосте
function restartNetwork( [Parameter( Position = 0 )] $config )
{
	$doRestartScriptPath = $( Join-Path -Path "$( $ThisScriptPath |Split-Path -parent )" -ChildPath "do-restart-network-on-host.sh" )
	Get-Content "$doRestartScriptPath" |Invoke-Command-by-SSH $config 'script=/tmp/$$-sh;cat -|sed ''s/\r$//g''>$script && sh $script; rm $script'
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
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )