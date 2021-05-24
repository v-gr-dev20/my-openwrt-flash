# !Powershell
# Вход в консоль удаленного хоста
while( 1 ) { ssh '-Jroot@127.0.0.1:2222' root@192.168.50.1; sleep 10; }
