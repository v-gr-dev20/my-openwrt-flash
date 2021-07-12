# !Powershell
# Скрипт запускает команду на удаленном хосте через ssh

function main
{
	param(
		[switch] $WithoutLog,
		[string] $SaveLogTo,
		[switch] $WithoutTimestamp,
		[string] $Description,
		[string] $RedirectStandardOutput,
		[Parameter( Mandatory, Position = 0 )][string] $command,
		[Parameter( Position = 1, ValueFromRemainingArguments = $true )][string[]] $commandArgs,
		# и здесь магия Powershell: ValueFromPipeline
		[Parameter( ValueFromPipeline )][PSObject[]]$inputLine
	)

	$anURNpartOfConfig = getURNpartFromConfig $config
	$input |Invoke-Command-by-SSH -MustSaveLog:( -not $WithoutLog ) -SaveLogTo:$SaveLogTo `
		-RedirectStandardOutput:$RedirectStandardOutput `
		-WithTimestamp:( -not $WithoutTimestamp ) -Description:"$Description" `
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
		$commandName	[ -c ] <command>
		$commandName	[ -c ] `"<command> [ <arg1> <arg2> ... ]`"
		$commandName	<device> [ -c ] <command> [ <arg1> <arg2> ... ]
		$commandName	<device> [ -c ] `"<command> [ <arg1> <arg2> ... ]`"
		$commandName	-c <command> <arg1> [ <arg2> ... ]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) `
	-or ( $Args.Count -in @( 1, 2 ) -and ( $Args[-1].ToLower() -in @( "-c", "--command" ) ) ) )
{
	outputHelp
	exit
}
$toSkipArgsCount = 0
New-Variable -Scope script -Name config  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( $Args[0].ToLower() -in @( "-c", "--command" ) ) {
		$toSkipArgsCount += 1 
		getConfig
	} elseif( 1 -eq $Args.Count ) {
		getConfig
	} else {
		$toSkipArgsCount += 1 
		if( $Args[1].ToLower() -in @( "-c", "--command" ) ) {
			$toSkipArgsCount += 1 
		}
		getConfig $Args[0] 
	}
)
$input |Invoke-Command { $input| main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )
