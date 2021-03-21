# !Powershell
# Вход в консоль удаленного хоста DIR-320-820D, подключенного к промежуточному хосту RT-AC87U
while( 1 ) { ssh '-oServerAliveInterval=30' '-Jadmin@grigorovich-fam4.ddns.net' '-p8022' root@127.0.0.1; sleep 10; }
