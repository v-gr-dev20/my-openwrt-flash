# !Powershell
# Общие фукции для выполнения команд на удаленном сервере с помощью ssh
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Формирует строку параметров командной строки ssh
function form-ssh-parameters( [Parameter( Position = 0 )] $config )
{
	<#assert#> if( [string]::IsNullOrEmpty( $config.server ) ) { throw }
	[string]$result = $config.server
	if( -not [string]::IsNullOrEmpty( $config.user ) ) {
		$result = $config.user + "@" + $result
	}
	$result
}

# Выполняет команду на удаленном сервере
# Сервер определяется одним из способов:
#		1) [string]$config.user, [string]$config.server (имя или IP-адрес),
#TODO:	2) [string]$config.URN - вида "user@hostname.or.ip",
#TODO:	3) [array]$config.URNs - вида @( "user@hostname.or.ip", ... ),
#TODO:	4) [hashtable]$config.URNs - вида @( { user:"userName", server:"hostname.or.ip" }, ... ),
function Invoke-Command-by-SSH( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $command )
{
	Invoke-Expression $( [string]::Concat( 'ssh ', $( form-ssh-parameters $config ), " '", "$command", "'" ) )
}

