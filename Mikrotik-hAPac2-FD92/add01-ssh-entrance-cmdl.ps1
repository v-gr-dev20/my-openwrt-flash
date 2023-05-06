# !Powershell
# Вход в консоль удаленного хоста
# while( 1 ) { ssh '-oServerAliveInterval=30' '-Jadmin@grigorovich4.freeddns.org' '-p8022' root@127.0.0.1; sleep 10; }
while( 1 ) { ssh '-Jroot@127.0.0.1:2222' '-p8022' root@127.0.0.1; sleep 10; }
