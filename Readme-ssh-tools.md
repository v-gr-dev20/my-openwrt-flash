Краткое описание проекта my-ssh-tools  
============================================
https://github.com/v-gr-dev20/my-ssh-tools/blob/dev%23ssh/Readme-ssh-tools.md  
https://github.com/v-gr-dev20/my-ssh-tools/tree/dev%23ssh

Это набор PowerShell-скриптов, использующих ssh, для работы с хостами в сети.

### Пререквизиты
1. Powershell v7.2
2. Клиент OpenSSH.

### Установка
```
PS> mkdir demo
PS> git clone --branch dev#ssh -- https://github.com/v-gr-dev20/my-ssh-tools.git demo
```
### Подготовка
```
PS> cd demo
PS> '{	"//": "Параметры в формате JSON"
PS> ,	URNs:
PS> 			[
PS> 				{	server:
PS> 							"remotehost.net"
PS> 				,	user:
PS> 							"root"
PS> 				}
PS> 			]
PS> }' > ./config.json
```
### Примеры использования
#### Удаленное выполнение команды
```
PS> ./scripts/Invoke-Command-by-SSH.ps1 -c uptime
```
#### Удаленное выполнение скрипта
```

PS> '#!/bin/sh
PS> uptime
PS> ' > ./script.sh
PS> ./scripts/Invoke-Script-by-SSH.ps1 -s ./script.sh
```
#### Копирование файлов на удаленный хост
```
PS> 'file1' > file1.txt
PS> 'file2' > file2.txt
PS> ./scripts/Put-Files.ps1 file1.txt,file2.txt /tmp
```
#### Загрузка файлов с удаленного хоста
```
PS> ./scripts/Get-Files.ps1 /tmp/file1.txt,/tmp/file2.txt
```
### Очистка после завершения
```
PS> cd ..
PS> rm -force -r demo
```
