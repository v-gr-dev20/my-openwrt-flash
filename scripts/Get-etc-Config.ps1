# !Powershell
# Скрипт сохраняет файлы конфигурации openwrt/etc/config/* из удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$projectName, $projectPath = getProjectNP
	$file = $commandLineArgs[0]
	if( [string]::IsNullOrEmpty( $file ) ) {
		$file = '*'
	}
	getFile( $file )
}

# Общие функции
. "$( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )"

# Сохраняет файл конфигурации openwrt/etc/config/$file
#	$file - имя файла конфигурации
function getFile( [Parameter( Position = 0 )][string] $file )
{
	$deviceURN = $config.user + "@" + $config.server
	$deviceName = $config.device
	<#assert#> if( [string]::IsNullOrEmpty( $file ) ) { throw }
	$projectName, $projectPath = getProjectNP
	scp "${deviceURN}:/etc/config/$file" "$projectPath/$deviceName/etc/config/"
}

# Сохраняет все файлы конфигурации openwrt/uci
function getAllFiles()
{
	getFile '*'
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName	*
		$commandName	ddns | dhcp | dropbear | firewall | fstab | luci
		$commandName	network | system | ubootenv | ucitrack | uhttpd | wireless
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
$config = getConfig
if( 1 -lt $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
main $Args