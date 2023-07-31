# !Powershell
# Скрипт запускает sh-скрипт на удаленном хосте через ssh

function main
{
	param(
		[switch] $WithoutLog,
		[String] $SaveLogTo,
		[switch] $WithoutTimestamp,
		[string] $Description,
		[Parameter( Mandatory, Position = 0 )][Alias( 's' )][string] $script,
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
	<#assert#> if( -not ( Test-Path -Path $scriptPath ) ) { throw }
	Invoke-Script-by-SSH -MustSaveLog:( -not $WithoutLog ) -SaveLogTo:$SaveLogTo `
		-WithTimestamp:( -not $WithoutTimestamp )  -Description:"$Description" `
		$config $scriptPath $scriptArgs
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выводит подсказку и завершает программу
function outputHelpAndExit()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName	[ -s ] <script>
		$commandName	<device> [ -s ] <script> [ <arg1> <arg2> ... ]
		$commandName	-s <script> <arg1> [ <arg2> ... ]
		$commandName	-h | --help
"
	exit
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) ) {
	outputHelpAndExit
}
$toSkipArgsCount = 0
New-Variable -Scope script -Name config  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( ( '-' -eq $Args[0][0] ) -or ( 1 -eq $Args.Count ) ) {
		getConfig
	} else {
		$toSkipArgsCount += 1
		getConfig $Args[0]
	}
)
try {
	Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )
} catch [System.Management.Automation.ParameterBindingException] {
	outputHelpAndExit
}
