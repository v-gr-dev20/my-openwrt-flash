#!/bin/sh
# Вывод текущего состояния сети с учетом информации об участниках сети

# Состояние
echo ''; echo ''
free
echo ''; echo ''
netstat -rn
echo ''; echo ''
ip addr || ifconfig

# Вывод списка участников сети
echo ''; echo ''
cat /tmp/dhcp.leases

# Вывод информации о доступности участников сети в настоящее время
echo ''; echo ''
cat /tmp/dhcp.leases | awk '{print $3}' |xargs -n1 ping -c2 -w1