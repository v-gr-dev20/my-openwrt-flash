#!/bin/sh
# ������� ����
# reboot � ������ ������� - ��� ���������� ������������ ���������� � ����

# ����������� ����� ������� ������� ����������� � ����
pingHost=8.8.8.8
# ����� � �������� �� �������������� ������������ ����� � ������ ���������� ����������� � ����
patienceTimeout=120

try() {
	ping -c1 -w$( expr $patienceTimeout \* 10 / 100 ) $pingHost
}

case "$1" in

	restart )
		sh $0 check &
		local checkPid=$!
		# ������� ���� �� ��������� �����
		/etc/init.d/network restart
		/etc/init.d/firewall restart
		/etc/init.d/dnsmasq restart
		try || reboot
		kill -9 $checkPid
	;;

	check )
		# �������� � ������������ � ������ �������
		sleep $patienceTimeout
		try || reboot
	;;

	* )
		sh $0 restart > /tmp/$( basename $0 |sed 's/\.[^\.]*$//g' ).log & 
		ps -w |grep -E "network|sleep" |grep -v grep
	;;

esac

