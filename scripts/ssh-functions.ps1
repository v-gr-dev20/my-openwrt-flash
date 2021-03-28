# !Powershell
# Общие фукции для выполнения команд на удаленном сервере с помощью ssh
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# include
. $( Join-Path -Path "$( $PSCommandPath |Split-Path -parent )" -ChildPath "common.ps1" )

# Извлекает из конфига последовательность адресов @( "user@hostname.or.ip", ... )
# Последовательность адресов определяется в конфиге одним из способов:
#	1) [string]$config.user, [string]$config.server (имя или IP-адрес),
#	2) [string]$config.URN - вида "user@hostname.or.ip",
#	3) [array]$config.URNs - вида @( "user@hostname.or.ip", ... ),
#	4) [hashtable[]]$config.URNs - вида @( { user:"userName", server:"hostname.or.ip" }, ... ),
function Get-URNs-Chain( [Parameter( Mandatory, Position = 0 )] $config )
{
	$result = New-Object System.Collections.Generic.List[System.String]
	if( [string] -eq  $config.GetType() ) {
		$result.Add( $config )
	} elseif( $config.GetType() -in [Object[]],[String[]] ) {
		$config |ForEach-Object {
			$result.Add( $( Get-URNs-Chain $PSItem ) )
		}
	} elseif( $null -ne $config.server ) {
		[string]$urn = $config.server
		if( -not [string]::IsNullOrEmpty( $config.user ) ) {
			$urn = $config.user + "@" + $urn
		}
		if( -not [string]::IsNullOrEmpty( $config.port ) ) {
			$urn = $urn + ":" + $config.port
		}
		$result.Add( $urn ) 
	} elseif( $null -ne $config.URN ) {
		$result.Add( [string]$config.URN )
	} elseif( $null -ne $config.URNs ) {
		$result += $( Get-URNs-Chain $config.URNs )
	} elseif( $null -ne $config.ssh ) {
		$result += $( Get-URNs-Chain $config.ssh )
	}
	$result
}

# Извлекает из конфига адресную часть удаленного хоста
function getURNpartFromConfig()
{
	Select-Hashtable-by-Keys $config "user","server","URN","URNs","ssh","port"
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

# Извлекает из конфига и формирует последовательность параметров командной строки ssh для доступа к удаленному серверу
# В простом случае выдает результат вида: @( "user@hostname.or.ip" )
# Для цепочки из 3 адресов выдает результат вида:
#	@( "-Juser1@hostname1.or.ip,user2@hostname2.or.ip", "user3@hostname3.or.ip" )
function get-ssh-parameters( [Parameter( Mandatory, Position = 0 )] $config )
{
	[string[]]$anURNsChain = Get-URNs-Chain $config

	if( 0 -eq $anURNsChain.Count ) {
		return @()
	}
	$result = New-Object Collections.Generic.List[string]
	if( 2 -le $anURNsChain.Count ) {
		$result.Add( '-J' + $anURNsChain[0] )
		if( 3 -le $anURNsChain.Count ) {
			$anURNsChain[ 1..( $anURNsChain.Count-2 ) ] `
			|ForEach-Object {
				$result[-1] += ',' + $PSItem
			}
		}
	}
	$lastSplitURN = &{ $anURNsChain[-1] -split ':' }
	if( 2 -le $lastSplitURN.Count -and -not [string]::IsNullOrEmpty( $lastSplitURN[-1] ) ) {
		$result.Add( '-p' + $lastSplitURN[-1] )
		$result.Add( $lastSplitURN[0] )
	} else {
		$result.Add( $lastSplitURN )
	}
	$result
}

# Преобразует массив строк вида @("w1 w2", "w3", "w4") в строку вида '"w1 w2" w3 w4'
function joinToStringWithQuotas( [Parameter( Position = 0 )][string[]] $items,
		[Parameter( Position = 1 )][string] $firstQuote = "`\`"",
		[Parameter( Position = 2 )][string] $secondQuote )
{
	if( [string]::IsNullOrEmpty( $secondQuote ) ){
		$secondQuote = $firstQuote
	}
	$result = ""
	foreach( $item in $items ) {
		if( $item -match "\s" ) {
			$result = "${result} ${firstQuote}${item}${secondQuote}"
		} else {
			$result = "${result} ${item}"
		}
	}
	$result
}

# Выполняет команду на удаленном сервере
# Параметры ssh формируются из конфига
function Invoke-Command-by-SSH
{
	[CmdletBinding()]
	param(
		[switch] $MustSaveLog = $true,
		[String] $SaveLogTo,
		[String] $RunLogHeader,
		[switch] $WithTimestamp = $true,
		[string] $RedirectStandardInput,
		[string] $RedirectStandardOutput,
		[string] $Description,
		[Parameter( Mandatory, Position = 0 )] $config, [Parameter( Position = 1 )][string] $command,
		[Parameter( Position = 2, ValueFromRemainingArguments )][string[]] $commandArgs,
		# и здесь магия Powershell: ValueFromPipeline
		[Parameter( ValueFromPipeline )][PSObject[]]$inputLine
	)

	[string[]]$sshParameters = get-ssh-parameters $config
	<#assert#> if( 0 -eq $sshParameters.Count -or [string]::IsNullOrEmpty( $command ) ) { throw }
	$commandArgsLine = joinToStringWithQuotas $commandArgs

	if( $MustSaveLog -xor -not [string]::IsNullOrEmpty( $SaveLogTo ) ) {
		if( -not $MustSaveLog ) {
			$MustSaveLog = [switch]$true
		} else {
			# имя лог-файла по-умолчанию
			$H = $sshParameters[-1] -replace '^.+\@(.+)$','$1'
			$T = Get-Date -Format 'yyyy-MM-dd-HHmmss'
			$SaveLogTo = "${env:userprofile}/Windows Terminal/${T}-${H}.log"
		}
	}
	if( [string]::IsNullOrEmpty( $RunLogHeader ) ) {
		$RunLogHeader = "command: $command"
	}
	$sshOriginalCommandBlock = {
		if( $MustSaveLog ) {
			Write-Output "Remote session: ssh $( joinToStringWithQuotas $sshParameters '`"' )"
			if( -not [string]::IsNullOrEmpty( $Description ) ) {
				Write-Output "Description: $Description"
			}
			Write-Output "Run $RunLogHeader"
			if( -not [string]::IsNullOrEmpty( $commandArgs ) ) {
				Write-Output "Arguments: $( joinToStringWithQuotas $commandArgs '`"' )"
			}
		}
		if( [string]::IsNullOrEmpty( $RedirectStandardOutput ) ) {
			if( [string]::IsNullOrEmpty( $RedirectStandardInput ) ) {
				$input |ssh $sshParameters "$command" $commandArgsLine
			} else {
				$redirectStandardError = New-TemporaryFile
				$redirectStandardOutput = New-TemporaryFile
				Start-Process -NoNewWindow -Wait `
					-RedirectStandardInput:$RedirectStandardInput `
					-RedirectStandardOutput:$redirectStandardOutput `
					-RedirectStandardError:$redirectStandardError `
					'ssh' ( $sshParameters + @( "$command" ) + $commandArgs )
				if( 0 -lt $redirectStandardOutput.Length ) {
					Get-Content $redirectStandardOutput.FullName
				}
				Remove-Item $redirectStandardOutput.FullName -force
				if( 0 -lt $redirectStandardError.Length ) {
					Get-Content $redirectStandardError.FullName
				}
				Remove-Item $redirectStandardError.FullName -force
			}
		} else {
			$redirectStandardError = New-TemporaryFile
			if( [string]::IsNullOrEmpty( $RedirectStandardInput ) ) {
				Start-Process -NoNewWindow -Wait `
					-RedirectStandardOutput:$RedirectStandardOutput `
					-RedirectStandardError:$redirectStandardError `
					'ssh' ( $sshParameters + @( "$command" ) + $commandArgs )
			} else {
				Start-Process -NoNewWindow -Wait `
					-RedirectStandardInput:$RedirectStandardInput `
					-RedirectStandardOutput:$RedirectStandardOutput `
					-RedirectStandardError:$redirectStandardError `
					'ssh' ( $sshParameters + @( "$command" ) + $commandArgs )
			}
			if( 0 -lt $redirectStandardError.Length ) {
				Get-Content $redirectStandardError.FullName
			}
			Remove-Item $redirectStandardError.FullName -force
		}
	}
	$sshTargetCommandBlock = $sshOriginalCommandBlock

	if( $WithTimestamp ) {
		$withTimestampInnerCommandBlock = $sshTargetCommandBlock
		$sshTargetCommandBlock = {
			$input |Invoke-Command -ScriptBlock $withTimestampInnerCommandBlock |%{ "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`t$_" }
		}
	}
	if( $MustSaveLog ) {
		$withLogInnerCommandBlock = $sshTargetCommandBlock
		$sshTargetCommandBlock = {
			$null = Start-Transcript -UseMinimalHeader -Append $SaveLogTo
			try
			{
				$input |Invoke-Command -ScriptBlock $withLogInnerCommandBlock 2>&1 |Out-Host
			}
			finally
			{
				$null = Stop-Transcript
			}
		}
	}
	# и здесь магия Powershell: $input
	$input |Invoke-Command -ScriptBlock $sshTargetCommandBlock
}

# Выполняет копирование файлов с/на удаленного сервера с помощью scp
# Параметры scp формируются из конфига
function Invoke-SCP( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string] $source,
	[Parameter( Position = 2 )][string] $destination )
{
	[string[]]$sshParameters = get-ssh-parameters $config
	# формируем параметры доступа к удаленному серверу
	if( 1 -le $sshParameters.Count -and -not [string]::IsNullOrEmpty( $sshParameters[-1] ) -and -not $sshParameters[-1].StartsWith( '-p' ) ) {
		$endURN = $sshParameters[-1]
		# проверяем вхождение URN хоста в путях к файлам
		if( ( ( $endURN.Length -lt $source.Length ) -and ( ( $endURN + ":" ) -ieq  $source.Substring( 0, $endURN.Length+1 ) )
			) -or ( ( $endURN.Length -lt $destination.Length ) -and ( ( $endURN + ":" ) -ieq $destination.Substring( 0, $endURN.Length+1 ) ) )
		  )
		{
			# убираем лишний хост в цепочке, т.к. он указан в пути к файлам на удаленном хосте
			if( 1 -eq $sshParameters.Count ) {
				$sshParameters = @()
			} else {
				$sshParameters = $sshParameters[0..( $sshParameters.Count-2 )]
			}
		} else {
			# объединяем последний URN с номером порта
			if( 2 -le $sshParameters.Count -and $sshParameters[-2].StartsWith( '-p' ) ) {
				$sshParameters[-2] = $sshParameters[-1] + ':' + $sshParameters[-2].substring( 2 )
				$sshParameters = $sshParameters[0..( $sshParameters.Count-2 )]
			}
			# добавляем хост в конец цепочки доступа, т.к. его нет в пути к файлам на удаленном хосте
			if( 1 -eq $sshParameters.Count ) {
				$sshParameters = @( '-J' + $sshParameters[0] )
			} else {
				$sshParameters[-2] += ',' + $sshParameters[-1]
				$sshParameters = $sshParameters[0..( $sshParameters.Count-2 )]
			}
		}
	}
	scp $sshParameters "$source" "$destination"
}

# Выполняет скрипт на удаленном хосте
function Invoke-Script-by-SSH(
	[switch] $MustSaveLog = $true,
	[String] $SaveLogTo,
	[switch] $WithTimestamp = $true,
	[string] $Description,
	[Parameter( Mandatory, Position = 0 )] $config, [Parameter( Position = 1 )][string] $script,
	[Parameter( Position = 2, ValueFromRemainingArguments )][string[]] $scriptArgs )
{
	$invokeScriptCommand = 'script=/tmp/$$-sh; wrappedRun(){ sh --login $script \"$@\"; rm $script; } ;cat -|sed ''s/\r$//g''>$script && wrappedRun'
	Get-Content $script |Invoke-Command-by-SSH -MustSaveLog:$MustSaveLog -SaveLogTo:$SaveLogTo `
		-WithTimestamp:$WithTimestamp -Description:"$Description" -RunLogHeader:"script $script" `
		$config $invokeScriptCommand $scriptArgs
}

# Копирует и перезаписывает указанные файлы с удаленного хоста в локальную папку
function Get-Files( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string[]] $remoteFiles,
	[Parameter( Position = 2 )][string] $localDestinationDirectory = ( Get-Location ).Path )
{
	if( 0 -eq $remoteFiles.Count ) {
		return
	}
	$tempFile = New-TemporaryFile
	Invoke-Command-by-SSH -MustSaveLog:$false -WithTimestamp:$false -RedirectStandardOutput:"$( $tempFile.FullName )" `
			$config 'tar' ( '-cf','-' + $remoteFiles )
	tar -C "$localDestinationDirectory" -xf "$( $tempFile.FullName )"
	Remove-Item $tempFile.FullName -force
}
