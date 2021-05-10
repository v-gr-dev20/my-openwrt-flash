# !Powershell
# Скрипт копирует локальные файлы на удаленный хост в указанную папку

function main( [Parameter( Mandatory )][string[]] $files,
		[Parameter( Mandatory )][string] $destination )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	Put-Files $anURNpartOfConfig -files:$files -remoteDestinationDirectory:$destination 
}

# Копирует и перезаписывает локальные файлы и папки на удаленный хост в указанную папку
function Put-Files( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string[]] $files,
	[Parameter( Mandatory, Position = 2 )][string] $remoteDestinationDirectory )
{
	if( 0 -eq $files.Count ) {
		return
	}
	$tempFile = New-TemporaryFile
	tar -cf $tempFile.FullName -C "$( $files[0] |Split-Path -parent )" "$( $files[0] |Split-Path -leaf )"
	foreach( $file in ( $files |Select-Object -Skip 1 ) ) {
		tar -rf $tempFile.FullName -C "$( $file |Split-Path -parent )" "$( $file |Split-Path -leaf )"
	}
	Invoke-Command-by-SSH -MustSaveLog:$false -WithTimestamp:$false -RedirectStandardInput:$tempFile.FullName `
			$config 'tar' ( '-xf', '-', '-C', $remoteDestinationDirectory )
	Remove-Item $tempFile.FullName -force
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName [ <device> ] <Path/of/localFile1>[,*2,..] <Path/of/destinationDir>
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 1 -le $Args.Count -and $Args[0].ToLower() -in @( "-h", "--help" ) ) `
	-or ( $Args.Count -lt 2 ) -or ( 3 -lt $Args.Count ) ) `
{
	outputHelp
	exit
}
$toSkipArgsCount = 0
New-Variable -Scope script -Name config  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( 2 -eq $Args.Count ) {
		getConfig
	} else {
		$toSkipArgsCount += 1 
		getConfig $Args[0] 
	}
)
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )