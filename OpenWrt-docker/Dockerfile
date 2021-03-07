FROM openwrtorg/rootfs:x86-64

# Установим необходимые пакеты
RUN opkg update && \
    opkg install openvpn-openssl luci-app-openvpn iptables ip-full iproute2 kmod-tun bash net-tools curl

# Копируем стартовый скрипт (если нужен)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Запуск через bash
CMD ["/entrypoint.sh"]
