# !Powershell
# Туннель для входа через порт 8888 socks-proxy в web-GUI целевого хоста
while( 1 ) {
	ssh -fTN -D8888 '-oServerAliveInterval=30' root@192.168.40.1
	ssh -fTN -D8888 '-oServerAliveInterval=30' root@grigorovich4.freeddns.org
	sleep 10
}
