# !Powershell
# Скрипт загружает на удаленный хост в папку /home расширенный набор opkg-пакетов и ключ, которым подписаны пакеты

# Будут распакованы файлы:
#	./openwrt/bin/targets/ar71xx/tiny/packages/*
#	./openwrt/bin/packages/mips_24kc/base/*
#	./openwrt/build_dir/target-mips_24kc_musl/root.orig-ar71xx/etc/opkg/keys/*
$tarFile = 'openwrt-mips_24kc-export-packages.tgz'
$targetDirOnHost = '/home'

function main( [string] $tarFilePath = $tarFile )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	putPackages $anURNpartOfConfig -tarFilePath:$tarFilePath
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Выполняет копирование и распаковку opkg-пакетов
function putPackages( [Parameter( Mandatory, Position = 0 )] $config,
	[string] $tarFilePath )
{
	Invoke-Command-by-SSH $config -Description:"Packages transfer to remote host" `
			-RedirectStandardInput:$tarFilePath `
			'tar' 'xzf','-',$( '-C"' + $targetDirOnHost + '"' )
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName [ <device> ] [ /path/to/packages.tgz ]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 1 -le $Args.Count -and $Args[0].ToLower() -in @( "-h", "--help" ) ) `
	-or ( 3 -lt $Args.Count ) `
	-or ( 2 -eq $Args.Count -and -not ( $Args[0].ToLower() -in @( "-k", "--keypath" ) ) ) `
	-or ( 3 -eq $Args.Count -and -not ( $Args[1].ToLower() -in @( "-k", "--keypath" ) ) ) )
{
	outputHelp
	exit
}
$toSkipArgsCount = 0
New-Variable -Scope script -Name config  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( 0 -eq $Args.Count -or ( $Args[0].ToLower() -in @( "-k", "--keypath" ) ) ) {
		getConfig
	} else {
		$toSkipArgsCount += 1
		getConfig $Args[0]
	}
)
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )