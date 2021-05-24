# !Powershell
# Вход в консоль удаленного хоста
while( 1 ) { ssh '-oServerAliveInterval=30' '-Jroot@grigorovich4.freeddns.org' root@192.168.40.1; sleep 10; }
