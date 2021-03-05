# !Powershell
# Скрипт запускает команду на удаленном хосте через ssh

function main
{
	param(
		[switch] $WithoutLog,
		[string] $SaveLogTo,
		[switch] $WithoutTimestamp,
		[Parameter( Mandatory, Position = 0 )][string] $command,
		[Parameter( Position = 1, ValueFromRemainingArguments = $true )][string[]] $commandArgs,
		# и здесь магия Powershell: ValueFromPipeline
		[Parameter( ValueFromPipeline )][PSObject[]]$inputLine
	)

	$anURNpartOfConfig = getURNpartFromConfig $config
	$input |Invoke-Command-by-SSH -MustSaveLog:( -not $WithoutLog ) -SaveLogTo:$SaveLogTo -WithTimestamp:( -not $WithoutTimestamp ) `
		$anURNpartOfConfig $command $commandArgs
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
New-Variable -Scope script -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
$input |Invoke-Command { $input| main @Args } -ArgumentList ( $Args |Select-Object -Skip 1 )