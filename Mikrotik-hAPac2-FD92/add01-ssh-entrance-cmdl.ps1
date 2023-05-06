# !Powershell
# Вход в консоль удаленного хоста
while( 1 ) {
	ssh '-oServerAliveInterval=30' '-Jroot@grigorovich5.freeddns.org' -p8022 root@127.0.0.1
	ssh '-oServerAliveInterval=30' '-Jroot@127.0.0.1:2250' -p8022 root@127.0.0.1
	ssh '-oServerAliveInterval=30' -p2220 root@127.0.0.1
	sleep 10
}
