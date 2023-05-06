# !Powershell
# Туннель через промежуточный хост для входа через порт 8888 socks-proxy в web-GUI целевого хоста, также соединенного с промежуточным хостом
# while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-Jadmin@grigorovich4.freeddns.org' '-p8022' root@127.0.0.1; sleep 10; }
while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-Jroot@127.0.0.1:2222' '-p8022' root@127.0.0.1; sleep 10; }
