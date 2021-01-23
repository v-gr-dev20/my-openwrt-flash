# !Powershell
# Скрипт запускает команду на удаленном хосте через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	<#assert#> if( 0 -eq $commandLineArgs.Count ) { throw }

	$anURNpartOfConfig = getURNpartFromConfig $config
	$command = $commandLineArgs[0]
	$commandArgs = @()
	if( 2 -le $commandLineArgs.Count ) {
		$commandArgs = $commandLineArgs[1..( $commandLineArgs.Count-1 )]
	}
	Invoke-Command-by-SSH $anURNpartOfConfig $command $commandArgs
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName <device> command
		$commandName <device> command line
		$commandName <device> `"command line`"
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 1 -eq $Args.Count -or 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )