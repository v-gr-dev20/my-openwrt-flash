#!Powershell
# Скрипт копирует указанные файлы с удаленного хоста в локальную папку

function main( [Parameter( Mandatory )][string[]] $files,
		[string] $destination = ( Join-Path ( $config.configPath |Split-Path -parent ) "rootfs" ) )
{
	if( !( Test-Path $destination ) ) {
		New-Item -Path $destination -ItemType Directory > $null
	}
	Get-Files $config -remoteFiles:$files -localDestinationDirectory:$destination `
		|?{ -not ( $_ -match "tar: removing leading '/' from member names" ) }
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
		$commandName	[ <device> ] <file1>[ ,<file2>... ]
		$commandName	[ <device> ] -files <file1>[ ,<file2>... ] [ -destination <directory> ]
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
	if( 1 -eq $Args.Count ) {
		# "магический" способ передать единственный параметр-массив
		Invoke-Command { main @Args } -ArgumentList ( , $Args )
	} else {
		Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )
	}
} catch [System.Management.Automation.ParameterBindingException] {
	outputHelpAndExit
}
