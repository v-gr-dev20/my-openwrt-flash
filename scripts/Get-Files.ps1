#!Powershell
# Скрипт копирует указанные файлы с удаленного хоста в локальную папку

function main( [Parameter( Mandatory )][string[]] $files,
		[string] $destination = ( Join-Path ( $config.configPath |Split-Path -parent ) "rootfs" ) )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	if( !( Test-Path $destination ) ) {
		New-Item -Path $destination -ItemType Directory > $null
	}
	Get-Files $anURNpartOfConfig -remoteFiles:$files -localDestinationDirectory:$destination 
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
		$commandName [ <device> ] -files <file1>,<file1> [ -destination <directory> ]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 1 -le $Args.Count -and $Args[0].ToLower() -in @( "-h", "--help" ) ) `
	-or ( -not ( $Args.Count -in @( 2, 3, 4, 5 ) ) ) `
	-or ( $Args.Count -in @( 2, 4 ) -and -not ( $Args[0].ToLower() -in @( "-f", "-files" ) ) ) `
	-or ( $Args.Count -in @( 3, 5 ) -and -not ( $Args[1].ToLower() -in @( "-f", "-files" ) ) ) `
	-or ( $Args.Count -in @( 4, 5 ) -and -not ( $Args[-2].ToLower() -in @( "-d", "-destination" ) ) ) )
{
	outputHelp
	exit
}
$toSkipArgsCount = 0
New-Variable -Scope script -Name config  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( $Args[0].ToLower() -in @( "-f", "-files" ) ) {
		getConfig
	} else {
		$toSkipArgsCount += 1 
		getConfig $Args[0] 
	}
)
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )