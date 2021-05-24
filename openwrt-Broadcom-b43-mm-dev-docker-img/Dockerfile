FROM openwrt-git:latest

WORKDIR /root/openwrt

RUN echo "\
CONFIG_TARGET_brcm47xx=y						\n\
CONFIG_TARGET_brcm47xx_legacy=y					\n\
CONFIG_TARGET_brcm47xx_legacy_Broadcom-b43=y	\n\
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5 toolchain/install

COPY configdiff ./configdiff

RUN cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5

# Сборка docker-образа с итоговым образом openwrt-прошивки,
#	префикс '-' исключает модуль из итоговой прошивки,
#	несмотря на '-', исключенный модуль доступен отдельно в расширенном наборе пакетов
WORKDIR /root/openwrt/build_dir/target-mipsel_mips32_musl/openwrt-imagebuilder-brcm47xx-legacy.Linux-x86_64
RUN FORCE_UNSAFE_CONFIGURE=1 IGNORE_ERRORS=1 \
	make image PROFILE="Broadcom-b43" PACKAGES="\
		base-files \
		busybox mtd uci nvram \
		swconfig \
		kmod-usb2 kmod-usb-ehci kmod-usb-ohci kmod-usb-uhci \
		kmod-fs-ext4 ubox block-mount kmod-scsi-core kmod-usb-storage \
		kmod-leds-gpio kmod-gpio-button-hotplug \
		kmod-ledtrig-default-on kmod-ledtrig-timer kmod-ledtrig-netdev \
#
# Исключен opkg
		-uclient-fetch -opkg \
#
# Исключены модули WiFi
		-libiwinfo -iwinfo -iw -iw-full -b43legacy-firmware -wireless-regdb -kmod-cfg80211 -kmod-mac80211 -kmod-b43 -kmod-b43legacy -wpad -wpad-mini -wpad-basic-wolfssl -hostapd-common \
#
# Включены модули ppp, pppoe
		ppp-mod-pppoe kmod-pppox kmod-pppoe kmod-ppp ppp \
#
# Исключен IPv4-odhcpd (его функции покрывает dnsmasq), оставлен только IPv6-odhcpd
		-odhcpd \
		dnsmasq -odhcp6c \
# IPv6-odhcpd
		-odhcpd-ipv6only \

#
# Реквизиты для подключения 4G-модема Huawei, прошитого в Hilink
# https://gist.github.com/bjoern-r/1345e8a17f4acf41006330e688af1441
# https://global-hotspot.ru/openwrt-huawei-e3372/
# https://geek-speak.ru/forums/topic/%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-usb-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D0%B0-%D0%B2-hilink-%D0%BD%D0%B0-openwrt-19-07-3/
		kmod-usb-net kmod-usb-net-cdc-ether \
#
# Реквизиты для подключения смартфона (также требуется наличие пакетов для 4G модема выше)
		kmod-usb-net-rndis \
#
# Реквизиты для подключения CDMA-модема Pantech UM150
		kmod-usb-serial kmod-usb-serial-option \
		kmod-usb-acm kmod-usb-serial-wwan \
		chat ppp comgt \
#
# Вспомогательные утилиты для проверки подключения устройств в usb (модема, HDD, flash)
		-usbutils \
#
# Утилита переключения из CD-режима usb-модема для возможности доступа к microSD
		usb-modeswitch \
#
# Утилита для поддержания удаленного соединения
		autossh \
#
# Утилиты для форматирования дисков
		e2fsprogs -fdisk -gdisk \
#
# Web-GUI (исключен)
		-luci \
#
# DDNS-скрипты
		ddns-scripts ddns-scripts_no-ip_com \
#
# Файловые системы
		-f2fs-tools -kmod-fs-f2fs \
		-dosfstools -kmod-fs-vfat \
		-ntfs-3g-utils -ntfs-3g \
		-kmod-fs-exfat \
#
# NLS
		-kmod-nls-cp1251 -kmod-nls-cp437 -kmod-nls-cp866 -kmod-nls-iso8859-1 -kmod-nls-utf8 \
"

WORKDIR /root/openwrt
RUN find . -name openwrt-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx -type f -ls
