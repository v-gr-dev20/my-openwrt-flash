# !Powershell
# Скрипт загружает образ прошивки на промежуточный хост и запускает вспомогательный скрипт прошивки целевого хоста

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	$serviceURNsChain = Get-URNs-Chain $anURNpartOfConfig
	<#assert#> if( 0 -eq $commandLineArgs.Count ) { throw }
	$firmwareBin = $commandLineArgs[0]
	<#assert#> if( 0 -eq $serviceURNsChain.Count ) { throw }
	if( 1 -eq $serviceURNsChain.Count ) {
		$serviceURNsChain = $()
		startFlashFromLocalHost $firmwareBin
	} else {
		$serviceURNsChain = $serviceURNsChain[0..( $serviceURNsChain.Count-2 )]
		startFlashFromServiceHost $serviceURNsChain $firmwareBin
	}
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Запускает процесс прошивки с локального хоста
function startFlashFromLocalHost( [Parameter( Position = 0 )][string] $firmwareBin )
{
	# пока не реализовано
	<#assert#> throw
}

# Запускает процесс прошивки с промежуточного хоста
function startFlashFromServiceHost( [Parameter( Position = 0 )] $serviceConfig, [Parameter( Position = 1 )][string] $firmwareBin )
{
	$flashScriptPath = Join-Path -Path $( $ThisScriptPath |Split-Path -parent  ) -ChildPath "firmware-flash.sh"
	$firmwarePathOnServiceHost = "/tmp/firmware.bin"
	[String[]]$serviceURNsChain = Get-URNs-Chain $serviceConfig
	<#assert#> if( 0 -eq $serviceURNsChain.Count ) { throw }
	$serviceHost = $serviceURNsChain[-1]
	Invoke-SCP $serviceConfig $firmwareBin "${serviceHost}:${firmwarePathOnServiceHost}" `
	&& Invoke-Script-by-SSH $serviceConfig $flashScriptPath $firmwarePathOnServiceHost |%{ "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$_" }
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