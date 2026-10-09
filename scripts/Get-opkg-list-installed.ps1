# !Powershell
# Скрипт сохраняет список установленных пакетов openwrt:opkg из удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$anURNpartOfConfig = getURNpartFromConfig $config
	if( -not ( Test-Path $projectPath -PathType Container ) ) {
		mkdir -p "$projectPath" > $null
	}
	getAndSaveOpkgList $anURNpartOfConfig "$projectPath/opkg-list-installed"
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Сохраняет файл конфигурации openwrt:uci
function getAndSaveOpkgList ( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $file )
{
	Invoke-Command-by-SSH $config -MustSaveLog:$false -WithTimestamp:$false -RedirectStandardOutput:"$file" `
		opkg list-installed
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName <device>
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 1 -lt $Args.Count -or 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Scope script -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )