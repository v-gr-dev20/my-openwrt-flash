# !Powershell
# Туннель через промежуточный хост RT-AC87 для входа через порт 8888 socks-proxy в web-GUI целевого хоста, также соединенного с промежуточным хостом RT-AC87U
while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-Jroot@grigorovich4.freeddns.org' root@192.168.40.1; sleep 10; }
