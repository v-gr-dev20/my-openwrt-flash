#!/bin/sh
# Рестарт сети
# reboot в случае неудачи - при отсутствии контрольного подключени в сети

# доступность хоста покажет наличие подключения к сети
pingHost=8.8.8.8
# время в секундах до принудительной перезагрузки хоста в случае отсутствия подключения к сети
patienceTimeout=120

try() {
	ping -c1 -w$( expr $patienceTimeout \* 10 / 100 ) $pingHost
}

case "$1" in

	restart )
		sh $0 check &
		local checkPid=$!
		# рестарт сети на удаленном хосте
		/etc/init.d/network restart
		/etc/init.d/firewall restart
		/etc/init.d/dnsmasq restart
		try || reboot
		kill -9 $checkPid
	;;

	check )
		# проверка и перезагрузка в случае неудачи
		sleep $patienceTimeout
		try || reboot
	;;

	* )
		sh $0 restart > /tmp/$( basename $0 |sed 's/\.[^\.]*$//g' ).log & 
		ps -w |grep -E "network|sleep" |grep -v grep
	;;

esac

