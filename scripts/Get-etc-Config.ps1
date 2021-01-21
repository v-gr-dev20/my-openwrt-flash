# !Powershell
# Скрипт сохраняет файлы конфигурации openwrt/etc/config/* из удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$file = '*'
	if( -not $commandLineArgs -eq $null ) {
		$file = $commandLineArgs[0]
	}
	getFileAndSave $file > $null
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Сохраняет файл конфигурации openwrt:/etc/config/$file
#	$file - имя файла конфигурации, либо *
function getFileAndSave( [Parameter( Position = 0 )][string] $file )
{
	<#assert#> if( [string]::IsNullOrEmpty( $file ) ) { throw }
	$deviceURN = Get-Host-URN $config
	<#assert#> if( [string]::IsNullOrEmpty( $deviceURN ) ) { throw }
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	Invoke-SCP $config "${deviceURN}:/etc/config/$file" "$projectPath/rootfs/etc/config/"
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
		$commandName <device>	*
		$commandName <device>	ddns | dhcp | dropbear | firewall | fstab | luci
		$commandName <device>	network | system | ubootenv | ucitrack | uhttpd | wireless
		$commandName -h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( 2 -lt $Args.Count -or 0 -eq $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )