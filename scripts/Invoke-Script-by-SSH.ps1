# !Powershell
# Скрипт запускает sh-скрипт на удаленном хосте через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	<#assert#> if( 0 -eq $commandLineArgs.Count ) { throw }

	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$scriptPath = $( Join-Path -Path $projectPath -ChildPath $commandLineArgs[0] )
	$anURNpartOfConfig = getURNpartFromConfig $config
	$scriptArgs = @()
	if( 2 -le $commandLineArgs.Count ) {
		$scriptArgs = $commandLineArgs[1..( $commandLineArgs.Count-1 )]
	}
	Invoke-Script-by-SSH $anURNpartOfConfig $scriptPath $scriptArgs
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
		$commandName <device> <script> [<arg1> <arg2> ...]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )