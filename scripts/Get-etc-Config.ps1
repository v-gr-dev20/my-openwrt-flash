# !Powershell
# Скрипт сохраняет в локальной папке файлы конфигурации openwrt:/etc,/usr/lib c удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$localTargetRoot = "$projectPath/rootfs"
	if( -not ( Test-Path $localTargetRoot -PathType Container ) ) {
		mkdir -p "$localTargetRoot" > $null
	}

	getAndSyncOpenwrtConfig $anURNpartOfConfig $localTargetRoot > $null 2>&1
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Синхронизирует файлы конфигурации openwrt в локальной папке (добавляются новые, удаляются отсутствующие, перезаписываются измененные)
function getAndSyncOpenwrtConfig( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $localTargetRoot )
{
	<#assert#> if( [string]::IsNullOrEmpty( $localTargetRoot ) ) { throw }
	$deviceURN = Get-Host-URN $config
	<#assert#> if( [string]::IsNullOrEmpty( $deviceURN ) ) { throw }

	# предварительно удаляем целевые файлы
	Remove-Item "${localTargetRoot}/*" -Force -Recurse -Confirm:$false

	# перечисление файлов конфигурации openwrt
	[string[]]$openwrtConfigItems = @(
		'/etc/config'
		'/etc/crontabs'
		'/etc/opkg.conf'
		'/etc/opkg/customfeeds.conf'
		'/etc/opkg/distfeeds.conf'
		'/usr/lib/opkg/status'
		'/rwm/upper/etc/config'
		'/rwm/upper/etc/crontabs'
		'/rwm/upper/usr/lib/opkg/status'
	)
	Get-Files $config $openwrtConfigItems $localTargetRoot
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
New-Variable -Scope script -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )