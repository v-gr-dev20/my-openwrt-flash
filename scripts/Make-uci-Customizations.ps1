# !Powershell
# Скрипт запускает изменение системных конфигураций на удаленном устройстве через ssh
# Изменение системных конфигураций - это sh-скрипт для подсистемы openwrt:uci batch

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$uciCustomizationsScriptPath = $( Join-Path -Path $projectPath -ChildPath "uci-customizations.sh" )
	$anURNpartOfConfig = getURNpartFromConfig $config
	makeUciCustomizations $anURNpartOfConfig $uciCustomizationsScriptPath
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выполняет запуск sh-скрипта с изменениями конфигураций на хосте
function makeUciCustomizations( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $uciCustomizationsScript )
{
	Invoke-Script-by-SSH $config $uciCustomizationsScript
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
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )