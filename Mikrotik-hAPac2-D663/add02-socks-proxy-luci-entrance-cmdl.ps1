# !Powershell
# Туннель через промежуточный хост RT-AC87 для входа через порт 8888 socks-proxy в web-GUI целевого хоста, также соединенного с промежуточным хостом RT-AC87U
while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-Jroot@127.0.0.1:2222' root@192.168.50.1; sleep 10; }
