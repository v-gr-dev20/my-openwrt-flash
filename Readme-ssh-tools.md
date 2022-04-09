������� �������� ������� my-ssh-tools  
============================================
https://github.com/v-gr-dev20/my-ssh-tools/blob/dev%23ssh/Readme-ssh-tools.md  
https://github.com/v-gr-dev20/my-ssh-tools/tree/dev%23ssh

��� ����� PowerShell-��������, ������������ ssh, ��� ������ � ������� � ����.

### ������������
1. Powershell v7.2
2. ������ OpenSSH.

### ���������
```
PS> mkdir demo
PS> git clone --branch dev#ssh -- https://github.com/v-gr-dev20/my-ssh-tools.git demo
```
### ����������
```
PS> cd demo
PS> '{	"//": "��������� � ������� JSON"
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
### ������� �������������
#### ��������� ���������� �������
```
PS> ./scripts/Invoke-Command-by-SSH.ps1 -c uptime
```
#### ��������� ���������� �������
```

PS> '#!/bin/sh
PS> uptime
PS> ' > ./script.sh
PS> ./scripts/Invoke-Script-by-SSH.ps1 -s ./script.sh
```
#### ����������� ������ �� ��������� ����
```
PS> 'file1' > file1.txt
PS> 'file2' > file2.txt
PS> ./scripts/Put-Files.ps1 file1.txt,file2.txt /tmp
```
#### �������� ������ � ���������� �����
```
PS> ./scripts/Get-Files.ps1 /tmp/file1.txt,/tmp/file2.txt
```
### ������� ����� ����������
```
PS> cd ..
PS> rm -force -r demo
```
