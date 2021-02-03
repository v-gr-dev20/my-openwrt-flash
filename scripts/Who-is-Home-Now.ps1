# !Powershell
# Скрипт-обертка через ssh получает и выводит текущее состояние сети удаленного хоста с учетом участников (/tmp/dhcp.leases)

# основной скрипт для запуска на удаленном хосте
$wrappedScript = "do-who-is-home-now-on-host.sh"

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	runWrappedScript $anURNpartOfConfig
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выполняет запуск скрипта на удаленном хосте
function runWrappedScript( [Parameter( Position = 0 )] $config )
{
	$wrappedScriptPath = $( Join-Path -Path "$( $ThisScriptPath |Split-Path -parent )" -ChildPath $wrappedScript )
	Invoke-Script-by-SSH $config $wrappedScriptPath
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