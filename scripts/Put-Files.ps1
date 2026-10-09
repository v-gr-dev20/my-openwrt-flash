# !Powershell
# Скрипт копирует локальные файлы на удаленный хост в указанную папку

function main( [Parameter( Mandatory )][string[]] $files,
		[Parameter( Mandatory )][string] $destination )
{
	Put-Files $config -files:$files -remoteDestinationDirectory:$destination 
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Выводит подсказку и завершает программу
function outputHelpAndExit()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName	[ <device> ] [ -files ] <Path/of/localFile1>[ ,<*File2>... ] [ -destination ] </Path/of/destinationDir>
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
	if( ( '-' -eq $Args[0][0] ) -or ( 2 -eq $Args.Count ) ) {
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
