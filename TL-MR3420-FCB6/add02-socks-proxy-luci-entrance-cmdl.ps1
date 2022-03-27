# !Powershell
# Туннель через промежуточный хост для входа через порт 8888 socks-proxy в web-GUI целевого хоста, также соединенного с промежуточным хостом
while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-p2222' root@127.0.0.1; sleep 10; }
