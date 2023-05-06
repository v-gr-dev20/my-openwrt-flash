# !Powershell
# Туннель через промежуточный хост для входа через порт 8820 socks-proxy в web-GUI целевого хоста, также соединенного с промежуточным хостом
while( 1 ) {
	ssh -fTN -D8820 '-oServerAliveInterval=30' '-Jroot@grigorovich5.freeddns.org' -p8022 root@127.0.0.1
	ssh -fTN -D8820 '-oServerAliveInterval=30' '-Jroot@127.0.0.1:2250' -p8022 root@127.0.0.1
	ssh -fTN -D8820 '-oServerAliveInterval=30' -p2220 root@127.0.0.1
	sleep 10
}
