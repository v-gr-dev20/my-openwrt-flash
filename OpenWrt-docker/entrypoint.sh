#!/bin/sh

# Настройка интерфейсов (если нужно вручную)
# ip addr add 192.168.1.1/24 dev eth0
# ip addr add 10.0.0.1/24 dev eth1

# Запуск OpenVPN, если конфиг есть
if [ -f /etc/openvpn/myvpn.conf ]; then
    echo "Starting OpenVPN..."
    openvpn --config /etc/openvpn/myvpn.conf
else
    echo "No OpenVPN config found, starting shell..."
    /bin/sh
fi
