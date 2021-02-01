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
function Get-URNs-Chain( [Parameter( Position = 0 )] $config )
{
	$result = New-Object System.Collections.Generic.List[System.String]
	if( [string] -eq  $config.GetType() ) {
		$result.Add( $config )
	} elseif( [Object[]] -eq  $config.GetType() ) {
		$config |ForEach-Object {
			$result.Add( $( Get-URNs-Chain $PSItem ) )
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
		$result += $( Get-URNs-Chain $config.URNs )
	}
	$result
}

# Извлекает из конфига последний или единственный URN хоста вида "user@hostname.or.ip"
function Get-Host-URN ( [Parameter( Position = 0 )] $config )
{	
	[string[]]$anURNsChain = Get-URNs-Chain $config
	if( 0 -eq $anURNsChain.Count ) {
		return $null
	}
	$anURNsChain[-1]
}

# Формирует подстроку параметров командной строки ssh для доступа к удаленному серверу
# В простом случае выдает результат вида: "user@hostname.or.ip"
# Для цепочки из 3 адресов выдает результат вида:
#	"-J user1@hostname1.or.ip,user2@hostname2.or.ip user3@hostname3.or.ip"
function form-ssh-parameters( [Parameter( Position = 0 )] $config )
{
	[array]$anURNsChain = Get-URNs-Chain $config

	if( 0 -eq $anURNsChain.Count ) {
		return ''
	}

	[string]$result = ''
	if( 2 -le $anURNsChain.Count ) {
		$result += '-J ' + $anURNsChain[0]
		if( 3 -le $anURNsChain.Count ) {
			$anURNsChain[ 1..( $anURNsChain.Count-2 ) ] `
			|ForEach-Object {
				$result += ',' + $PSItem
			}
		}
		$result += ' '
	}
	$result += $anURNsChain[-1]

	$result
}

# Выполняет команду на удаленном сервере
# Параметры ssh формируются из конфига
function Invoke-Command-by-SSH
{
	[CmdletBinding()]
	param(
		[Parameter( Position = 0 )] $config, [Parameter( Position = 1 )][string] $command,
		# и здесь магия Powershell: ValueFromPipeline
		[Parameter( ValueFromPipeline )][PSObject[]]$inputLine
	)

	$parametersAsString = form-ssh-parameters $config
	<#assert#> if( [string]::IsNullOrEmpty( $parametersAsString ) -and -not [string]::IsNullOrEmpty( $command ) ) { throw }
	[string[]]$parameters = -split $parametersAsString
	# и здесь магия Powershell: $input
	$input |ssh $parameters "$command"
}

# Выполняет копирование файлов с/на удаленного сервера с помощью scp
# Параметры scp формируются из конфига
function Invoke-SCP( [Parameter( Position = 0 )] $config,
	[Parameter( Position = 1 )][string] $source,
	[Parameter( Position = 2 )][string] $destination )
{
	$parametersAsString = form-ssh-parameters $config
	[string[]]$parameters = -split $parametersAsString
	# формируем параметры доступа к удаленному серверу
	if( -not [string]::IsNullOrEmpty( $parameters[-1] ) ) {
		$endURN = $parameters[-1]
		# проверяем вхождение URN хоста в путях к файлам
		if( ( ( $endURN.Length -lt $source.Length ) -and ( ( $endURN + ":" ) -ieq  $source.Substring( 0, $endURN.Length+1 ) )
			) -or ( ( $endURN.Length -lt $destination.Length ) -and ( ( $endURN + ":" ) -ieq $destination.Substring( 0, $endURN.Length+1 ) ) )
		  )
		{
			# убираем лишний хост в цепочке, т.к. он указан в пути к файлам на удаленном хосте
			if( 1 -eq $parameters.Count ) {
				$parameters = @()
			} else {
				$parameters = $parameters[0..( $parameters.Count-2 )]
			}
		} else {
			# добавляем хост в конец цепочки доступа, т.к. его нет в пути к файлам на удаленном хосте
			if( 1 -eq $parameters.Count ) {
				$parameters = @( '-J', $parameters[0] )
			} else {
				$parameters[-2] += ',' + $parameters[-1]
				$parameters = $parameters[0..( $parameters.Count-2 )]
			}
		}
	}
	scp $parameters "$source" "$destination"
}

