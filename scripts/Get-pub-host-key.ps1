# !Powershell
# Скрипт получает и сохраняет публичный ключ удаленного хоста

function main( [Parameter( Position = 0 )][string[]] $commandLineArgs )
{
	$deviceName = $config.projectName
	$projectPath = getProject $deviceName
	$anURNpartOfConfig = getURNpartFromConfig $config
	$hostPublicKeyPath = ''
	if( 0 -eq $commandLineArgs.Count ) {
		$hostPublicKeyPath = Join-Path $projectPath 'dropbear_rsa_host_key.pub'
	} elseif( '-' -ne $commandLineArgs[0] ) {
		$hostPublicKeyPath = $commandLineArgs[0] 
	}
	if( [string]::IsNullOrEmpty( $hostPublicKeyPath ) ) {
		getPubKey $anURNpartOfConfig
	} else {
		getPubKey $anURNpartOfConfig > $hostPublicKeyPath
	}
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Получает из удаленного хоста публичный ключ и выводит его
function getPubKey( [Parameter( Position = 0 )] $config )
{
	Invoke-Command-by-SSH $config -MustSaveLog:$false -WithTimestamp:$false "dropbearkey -y -f  /etc/dropbear/dropbear_rsa_host_key |grep -E '^ssh-rsa '"
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName  <device> [ - | </Path/to/save/key.pub> ]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( $Args.Count -lt 1 -or 2 -lt $Args.Count -or $Args[0].ToLower() -in @( "-h", "--help" ) ) {
	outputHelp
	exit
}
New-Variable -Name config  -Value ( getConfig $Args[0] ) -Option ReadOnly
main( $Args | Select-Object -Skip 1 )