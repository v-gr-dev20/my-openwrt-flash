# !Powershell
# Туннель через промежуточный хост RT-AC87 для входа через порт 8888 socks-proxy в web-GUI целевого хоста DIR-320-820D, также соединенного с промежуточным хостом RT-AC87U
while( 1 ) { ssh -fTN -D8888 '-oServerAliveInterval=30' '-Jadmin@grigorovich4.ddns.net' '-p8022' root@127.0.0.1; sleep 10; }
