#!/bin/sh
# Рестарт firewall
# reboot в случае неудачи - при отсутствии контрольного подключени в сети

# доступность хоста покажет наличие подключения к сети
pingHost=8.8.8.8
# время в секундах до принудительной перезагрузки хоста в случае отсутствия подключения к сети
patienceTimeout=60
# время в секундах меджу контрольными тестами на подключение
testTimeout=5

try() {
	ping -c1 -w$( expr $patienceTimeout * 10 / 100 ) $pingHost
}

# рестарт firewall на удаленном хосте и перезагрузка после неудачи
(((/etc/init.d/firewall restart &) ;sleep $patienceTimeout ;try > /dev/null 2>&1 || reboot )&)& 

ps -w |grep -E "firewall|network|sleep" |grep -v grep

# контроль подключения
tryRest=$( expr $patienceTimeout / $testTimeout + 1 )
while [[ 0 -lt $tryRest ]]
do
	sleep $testTimeout
	if try ;then break ;fi
	tryRest=$( expr $tryRest - 1 )
done |while read line ;do
	# контрольный вывод в случае сохранения подключения к терминалу
	echo "$( date '+%F %H:%M:%S' )	$line"
done
