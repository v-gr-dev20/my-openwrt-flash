# !Powershell
# Общие фукции для выполнения команд на удаленном сервере с помощью ssh
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Извлекает из конфига последовательность адресов @( "user@hostname.or.ip", ... )
# Последовательность адресов определяется в конфиге одним из способов:
#	1) [string]$config.user, [string]$config.server (имя или IP-адрес),
#	2) [string]$config.URN - вида "user@hostname.or.ip",
#	3) [array]$config.URNs - вида @( "user@hostname.or.ip", ... ),
#	4) [hashtable[]]$config.URNs - вида @( { user:"userName", server:"hostname.or.ip" }, ... ),
function get-URNs-chain( [Parameter( Position = 0 )] $config )
{
	$result = New-Object System.Collections.Generic.List[System.String]
	if( [string] -eq  $config.GetType() ) {
		$result.Add( $config )
	} elseif( [Object[]] -eq  $config.GetType() ) {
		$config |ForEach-Object {
			$result.Add( $( get-URNs-chain $PSItem ) )
		}
	} elseif( $null -ne $config.server ) {
		[string]$urn = $config.server
		if( -not [string]::IsNullOrEmpty( $config.user ) ) {
			$urn = $config.user + "@" + $urn
		}
		$result.Add( $urn ) 
	} elseif( $null -ne $config.URN ) {
		$result.Add( [string]$config.URN )
	} elseif( $null -ne $config.URNs ) {
		$result += $( get-URNs-chain $config.URNs )
	}
	$result
}

# Формирует подстроку параметров командной строки ssh для доступа к удаленному серверу
# В простом случае выдает результат вида: "user@hostname.or.ip"
# Для цепочки из 3 адресов выдает результат вида:
#	"-J user1@hostname1.or.ip,user2@hostname2.or.ip user3@hostname3.or.ip"
function form-ssh-parameters( [Parameter( Position = 0 )] $config )
{
	[array]$URNsChain = get-URNs-chain $config

	if( 0 -eq $URNsChain.Count ) {
		return ''
	}

	[string]$result = ''
	if( 2 -le $URNsChain.Count ) {
		$result += '-J ' + $URNsChain[0]
		if( 3 -le $URNsChain.Count ) {
			$URNsChain[ 1..( $URNsChain.Count-2 ) ] `
			|ForEach-Object {
				$result += ',' + $PSItem
			}
		}
		$result += ' '
	}
	$result += $URNsChain[-1]

	$result
}

# Выполняет команду на удаленном сервере
# Параметры ssh формируются из конфига
function Invoke-Command-by-SSH( [Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $command )
{
	$parametersAsString = form-ssh-parameters $config
	<#assert#> if( [string]::IsNullOrEmpty( $parametersAsString ) -and -not [string]::IsNullOrEmpty( $command ) ) { throw }
	[string[]]$parameters = -split $parametersAsString
	ssh $parameters "$command"
}

