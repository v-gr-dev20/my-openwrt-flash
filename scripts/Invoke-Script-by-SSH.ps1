# !Powershell
# Скрипт запускает sh-скрипт на удаленном хосте через ssh

function main
{
	param(
		[switch] $WithoutLog,
		[String] $SaveLogTo,
		[switch] $WithoutTimestamp,
		[string] $Description,
		[Parameter( Mandatory, Position = 0 )][string] $script,
		[Parameter( Position = 1, ValueFromRemainingArguments = $true )][string[]] $scriptArgs
	)

	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$scriptPath = $null
	foreach( $item in @(
				$script,
				$( Join-Path $projectPath $script ),
				$( Join-Path $projectPath "../scripts" $script )
			) )
	{
		if( Test-Path -Path $item ) {
			$scriptPath = Resolve-Path -Path $item
			break
		}
	}
	$anURNpartOfConfig = getURNpartFromConfig $config
	
	<#assert#> if( -not ( Test-Path -Path $scriptPath ) ) { throw }
	Invoke-Script-by-SSH -MustSaveLog:( -not $WithoutLog ) -SaveLogTo:$SaveLogTo `
		-WithTimestamp:( -not $WithoutTimestamp )  -Description:"$Description" `
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
New-Variable -Scope script -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip 1 )