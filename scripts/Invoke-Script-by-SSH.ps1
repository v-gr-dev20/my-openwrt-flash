# !Powershell
# Скрипт запускает sh-скрипт на удаленном хосте через ssh

function main
{
	[CmdletBinding( PositionalBinding = $false )]
	param(
		[Parameter( Mandatory = $false )][switch] $WithoutLog,
		[Parameter( Mandatory = $false )][String] $SaveLogTo,
		[Parameter( Mandatory = $false )][switch] $WithoutTimestamp,
		[Parameter( Mandatory = $true, Position = 0 )][string] $script,
		[Parameter( Mandatory = $false, Position = 1, ValueFromRemainingArguments = $true )][string[]] $scriptArgs
	)

	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$scriptPath = $( Join-Path -Path $projectPath -ChildPath $script )
	if( Test-Path -Path $scriptPath ) {
		$scriptPath = Resolve-Path -Path $scriptPath
	} elseif( Test-Path -Path $script ) {
		$scriptPath = Resolve-Path -Path $script
	}
	$anURNpartOfConfig = getURNpartFromConfig $config
	
	<#assert#> if( -not ( Test-Path -Path $scriptPath ) ) { throw }
	Invoke-Script-by-SSH -MustSaveLog:( -not $WithoutLog ) -SaveLogTo:$SaveLogTo -WithTimestamp:( -not $WithoutTimestamp ) `
		$anURNpartOfConfig $scriptPath $scriptArgs
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
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip 1 )