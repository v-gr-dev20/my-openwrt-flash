#!/bin/sh
# ����� �������� ��������� ���� � ������ ���������� �� ���������� ����

# ���������
echo ''; echo ''
free
echo ''; echo ''
netstat -rn
echo ''; echo ''
ip addr || ifconfig

# ����� ������ ���������� ����
echo ''; echo ''
cat /tmp/dhcp.leases

# ����� ���������� � ����������� ���������� ���� � ��������� �����
echo ''; echo ''
cat /tmp/dhcp.leases | awk '{print $3}' |xargs -n1 ping -c2 -w1