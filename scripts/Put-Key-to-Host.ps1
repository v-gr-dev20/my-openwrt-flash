# !Powershell
# Скрипт копирует публичный ключ на удаленный хост (под управлением openwrt/dropbear),
#	что делает возможным беспарольный доступ к хосту

$defaultPublicKeyPath = Join-Path ${env:USERPROFILE} '.ssh/id_rsa.pub'

function main( [string] $keyPath = $defaultPublicKeyPath )
{
	$anURNpartOfConfig = getURNpartFromConfig $config
	putKey $anURNpartOfConfig -keypath:$keyPath
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "ssh-functions.ps1" )

# Выполняет копирование ключа
function putKey( [Parameter( Mandatory, Position = 0 )] $config,
	[string] $keyPath )
{
	$keyFingerprint = $( ssh-keygen -l -f "$keyPath" )
	&{'
		newKey=/tmp/$$key.pub
		onHostKeys=/etc/dropbear/authorized_keys
		{
			cat << $$THE#END$$'

			# выводим ключ
			Get-Content -Path $keyPath

			'$$THE#END$$
		} |sed ''/^[\t ]\{0,\}$/d'' > $newKey
		ssh-keygen -l -f $newKey
		onHostKeysCount=$( cat $onHostKeys |sort |uniq |wc -l )
		withNewKeyCount=$( { cat $onHostKeys; cat $newKey; } |sort |uniq |wc -l )
		echo "' + $keyFingerprint + '"
		[[ $onHostKeysCount -lt $withNewKeyCount ]] && {
			cat $newKey >> $onHostKeys
			echo "New key added"
		} || {
			echo "The key is already present"
		}
		rm $newKey
	'} |Invoke-Command-by-SSH $config -Description:"Key transfer to remote host" `
			'wrappedRun(){ sh -s; }; cat - |sed ''s/\r$//g'' |wrappedRun'
}

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName [ <device> ] [ -keypath <Path/of/publicKeyFile> ]
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