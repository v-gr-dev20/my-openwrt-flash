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
	if( $config.GetType() -in [string],[String[]] ) {
		# пропускаем простые неструктурированные строковые параметры
	} elseif( [Object[]] -eq $config.GetType() ) {
		$config |ForEach-Object {
			$forAdd = ( Get-URNs-Chain $PSItem )
			if( $null -ne $forAdd ) {
				$result.Add( $forAdd )
			}
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
		$result += ( Get-URNs-Chain $config.ssh )
	}
	$result
}

# Извлекает из конфига адресную часть удаленного хоста
function getURNpartFromConfig()
{
	Select-Hashtable-by-Keys $config "user","server","URN","URNs","ssh","port"
}

# Извлекает из конфига опции для ssh (без адресной части)
function getSshOptionsFromConfig( [Parameter( Mandatory, Position = 0 )] $config )
{
	$result = New-Object System.Collections.Generic.List[System.String]
	$config.ssh |ForEach-Object {
		if( $null -ne  $PSItem ) {
			if( [string] -eq  $PSItem.GetType() ) {
				$result.Add( $PSItem )
			} elseif( $PSItem.GetType() -in [Object[]],[String[]] ) {
				$PSItem |ForEach-Object {
					if( [string] -eq  $PSItem.GetType() ) {
						$result.Add( $PSItem )
					}
				}
			}
		}
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

# Извлекает из конфига и формирует последовательность параметров командной строки ssh для доступа к удаленному серверу
# В простом случае выдает результат вида: @( "user@hostname.or.ip" )
# Для цепочки из 3 адресов выдает результат вида:
#	@( "-Juser1@hostname1.or.ip,user2@hostname2.or.ip", "user3@hostname3.or.ip" )
function get-ssh-parameters( [Parameter( Mandatory, Position = 0 )] $config )
{
	[string[]]$anURNsChain = Get-URNs-Chain $config
	[string[]]$sshOptions = getSshOptionsFromConfig $config

	if( ( 0 -eq $anURNsChain.Count ) -and ( 0 -eq $sshOptions.Count ) ) {
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
	$lastSplitURN = $( if( 1 -le $anURNsChain.Count ) { $anURNsChain[-1] -split ':' } )
	if( 2 -le $lastSplitURN.Count -and -not [string]::IsNullOrEmpty( $lastSplitURN[-1] ) ) {
		$result.Add( '-p' + $lastSplitURN[-1] )
		$result.Add( $lastSplitURN[0] )
	} else {
		$result.Add( $lastSplitURN )
	}
	if( 0 -lt $sshOptions.Count ) {
		$result = $sshOptions + $result
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

# Складывает в общую последовательность два набора параметров для вызова ssh
function combineSshOptionsWithConfig( [Parameter( Mandatory, Position = 0 )] $config,
		[Parameter( Position = 1 )][string[]] $sshOptions )
{
	if( 0 -eq $sshOptions.Count ) {
		$config
	} else {
		$newConfig = $config.Clone()
		if( $null -ne $config.ssh ) {
			$newConfig['ssh'] = $sshOptions + $newConfig.ssh
		} else {
			$newConfig['ssh'] = $sshOptions
		}
		$newConfig
	}
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
		[string[]] $SshOptions,
		[string] $Description,
		[Parameter( Mandatory, Position = 0 )] $config, [Parameter( Position = 1 )][string] $command,
		[Parameter( Position = 2, ValueFromRemainingArguments )][string[]] $commandArgs,
		# и здесь магия Powershell: ValueFromPipeline
		[Parameter( ValueFromPipeline )][PSObject[]]$inputLine
	)

	[string[]]$sshParameters = get-ssh-parameters ( combineSshOptionsWithConfig $config $SshOptions )
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
	if( $null -ne $config.projectPath ) { Push-Location $config.projectPath }
	# и здесь магия Powershell: $input
	$input |Invoke-Command -ScriptBlock $sshTargetCommandBlock
	if( $null -ne $config.projectPath ) { Pop-Location }
}

# Выполняет копирование файлов с/на удаленного сервера с помощью scp
# Параметры scp формируются из конфига
function Invoke-SCP( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string] $source,
	[Parameter( Position = 2 )][string] $destination ,
	[string[]] $SshOptions )
{
	[string[]]$sshParameters = get-ssh-parameters ( combineSshOptionsWithConfig $config $SshOptions )
	# формируем параметры доступа к удаленному серверу
	if( 1 -le $sshParameters.Count -and -not [string]::IsNullOrEmpty( $sshParameters[-1] )`
		-and -not $sshParameters[-1].StartsWith( '-' ) )
	{
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
			if( ( 2 -le $sshParameters.Count ) -and $sshParameters[-2].StartsWith( '-J' ) -and ( -not $sshParameters[-1].StartsWith( '-' ) ) ) {
				$sshParameters[-2] += ',' + $sshParameters[-1]
				$sshParameters = $sshParameters[0..( $sshParameters.Count-2 )]
			} elseif( -not $sshParameters[-1].StartsWith( '-' ) ) {
				$sshParameters[-1] = '-J' + $sshParameters[-1]
			}
		}
	}
	if( $null -ne $config.projectPath ) { Push-Location $config.projectPath }
	scp $sshParameters "$source" "$destination"
	if( $null -ne $config.projectPath ) { Pop-Location }
}

# Выполняет скрипт на удаленном хосте
function Invoke-Script-by-SSH(
	[switch] $MustSaveLog = $true,
	[String] $SaveLogTo,
	[switch] $WithTimestamp = $true,
	[string[]] $SshOptions,
	[string] $Description,
	[Parameter( Mandatory, Position = 0 )] $config, [Parameter( Position = 1 )][string] $script,
	[Parameter( Position = 2, ValueFromRemainingArguments )][string[]] $scriptArgs )
{
	$invokeScriptCommand = 'script=/tmp/$$-sh; wrappedRun(){ sh --login $script \"$@\"; rm $script; } ;cat -|sed ''s/\r$//g''>$script && wrappedRun'
	Get-Content $script |Invoke-Command-by-SSH -MustSaveLog:$MustSaveLog -SaveLogTo:$SaveLogTo `
		-WithTimestamp:$WithTimestamp -Description:"$Description" -RunLogHeader:"script $script" `
		-SshOptions:$SshOptions `
		$config $invokeScriptCommand $scriptArgs
}

# Копирует и перезаписывает указанные файлы с удаленного хоста в локальную папку
function Get-Files( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string[]] $remoteFiles,
	[Parameter( Position = 2 )][string] $localDestinationDirectory = ( Get-Location ).Path,
	[string[]] $SshOptions )
{
	if( 0 -eq $remoteFiles.Count ) {
		return
	}
	$tempFile = New-TemporaryFile
	Invoke-Command-by-SSH -MustSaveLog:$false -WithTimestamp:$false -RedirectStandardOutput:"$( $tempFile.FullName )" `
		-SshOptions:$SshOptions `
		$config 'tar' ( '-cf','-' + $remoteFiles )
	tar -C "$localDestinationDirectory" -xf "$( $tempFile.FullName )"
	Remove-Item $tempFile.FullName -force
}

# Копирует и перезаписывает локальные файлы и папки на удаленный хост в указанную папку
function Put-Files( [Parameter( Mandatory, Position = 0 )] $config,
	[Parameter( Mandatory, Position = 1 )][string[]] $files,
	[Parameter( Mandatory, Position = 2 )][string] $remoteDestinationDirectory,
	[string[]] $SshOptions )
{
	if( 0 -eq $files.Count ) {
		return
	}
	$tempFile = New-TemporaryFile
	tar -cf $tempFile.FullName -C "$( Resolve-Path $files[0] |Split-Path -parent )" "$( $files[0] |Split-Path -leaf )"
	foreach( $file in ( $files |Select-Object -Skip 1 ) ) {
		tar -rf $tempFile.FullName -C "$( Resolve-Path $file |Split-Path -parent )" "$( $file |Split-Path -leaf )"
	}
	Invoke-Command-by-SSH -MustSaveLog:$false -WithTimestamp:$false -RedirectStandardInput:$tempFile.FullName `
		-SshOptions:$SshOptions `
		$config 'tar' ( '-xf', '-', '-C', $remoteDestinationDirectory )
	Remove-Item $tempFile.FullName -force
}
