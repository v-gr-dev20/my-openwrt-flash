# !Powershell
# Вход в консоль удаленного хоста
while( 1 ) {
	ssh '-oServerAliveInterval=30' root@192.168.40.1
	ssh '-oServerAliveInterval=30' root@grigorovich4.freeddns.org
	sleep 10
}
