# !Powershell
# Скрипт загружает образ прошивки на конечный хост, запуская процесс прошивки

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	<#assert#> if( 0 -eq $commandLineArgs.Count ) { throw }
	$firmwareBin = $commandLineArgs[0]
	sysupgrade $anURNpartOfConfig $firmwareBin
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Запускает процесс прошивки на удаленном хосте
function sysupgrade( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $firmwareBin )
{
	$firmwarePathOnServiceHost = "/tmp/firmware.bin"
	[String[]]$anURNsChain = Get-URNs-Chain $config
	<#assert#> if( 0 -eq $anURNsChain.Count ) { throw }
	$targetURN = $anURNsChain[-1]
	Invoke-SCP $config $firmwareBin "${targetURN}:${firmwarePathOnServiceHost}" `
	&& Invoke-Command-by-SSH $config "sysupgrade" `-n `-v $firmwarePathOnServiceHost |%{ "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$_" }
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName  <device> <firmware.bin>
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 2 -ne $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )