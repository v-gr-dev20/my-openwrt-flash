# !Powershell
# Скрипт сохраняет файлы конфигурации openwrt:uci из удаленного устройства через ssh

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$anURNpartOfConfig = getURNpartFromConfig $config
	if( -not ( Test-Path $projectPath -PathType Container ) ) {
		mkdir -p "$projectPath" > $null
	}
	getAndSaveUciConfig $anURNpartOfConfig "$projectPath/${deviceName}-uci"
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Сохраняет файл конфигурации openwrt:uci
function getAndSaveUciConfig ( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $file )
{
	Invoke-Command-by-SSH $config -MustSaveLog:$false -WithTimestamp:$false uci show > "$file"
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