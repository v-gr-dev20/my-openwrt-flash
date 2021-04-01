FROM openwrt-git:latest

WORKDIR /root/openwrt

RUN echo "\
CONFIG_TARGET_ar71xx=y							\n\
CONFIG_TARGET_ar71xx_tiny=y						\n\
CONFIG_TARGET_ar71xx_tiny_DEVICE_tl-mr3420-v1=y	\n\
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5 toolchain/install

RUN echo "\
CONFIG_IB=y										\n\
CONFIG_IB_STANDALONE=y							\n\
CONFIG_JSON_OVERVIEW_IMAGE_INFO=y				\n\
CONFIG_KERNEL_SWAP=y							\n\
CONFIG_PACKAGE_kmod-usb2=y						\n\
CONFIG_PACKAGE_kmod-usb-ohci=y					\n\
CONFIG_PACKAGE_kmod-usb-storage=y				\n\
CONFIG_PACKAGE_kmod-fs-ext4=y					\n\
CONFIG_PACKAGE_block-mount=y					\n\
CONFIG_PACKAGE_kmod-scsi-core=y					\n\
CONFIG_PACKAGE_odhcpd=n							\n\
CONFIG_PACKAGE_odhcpd-ipv6only=y				\n\
CONFIG_PACKAGE_kmod-leds-gpio=y					\n\
CONFIG_PACKAGE_kmod-ledtrig-default-on=y		\n\
CONFIG_PACKAGE_kmod-ledtrig-timer=y				\n\
CONFIG_PACKAGE_kmod-ledtrig-netdev=y			\n\
CONFIG_PACKAGE_kmod-usb-ledtrig-usbport=y		\n\
CONFIG_PACKAGE_usb-modeswitch=y					\n\
CONFIG_PACKAGE_kmod-usb-net=y					\n\
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y			\n\
CONFIG_PACKAGE_usbutils=y						\n\
CONFIG_PACKAGE_autossh=y						\n\
CONFIG_PACKAGE_e2fsprogs=y						\n\
CONFIG_PACKAGE_fdisk=y							\n\
CONFIG_PACKAGE_luci=y							\n\
CONFIG_PACKAGE_kmod-ath=m						\n\
CONFIG_PACKAGE_kmod-ath9k-common=m				\n\
CONFIG_PACKAGE_kmod-ath9k=m						\n\
CONFIG_PACKAGE_wpad-mini=y						\n\
CONFIG_DEFAULT_kmod-ath9k=n						\n\
CONFIG_DEFAULT_wpad-mini=n						\n\
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5

# Сборка docker-образа с итоговым образом openwrt-прошивки,
#	префикс '-' исключает модуль из итоговой прошивки,
#	несмотря на '-', исключенный модуль доступен отдельно в расширенном наборе пакетов
WORKDIR /root/openwrt/build_dir/target-mips_24kc_musl/openwrt-imagebuilder-ar71xx-tiny.Linux-x86_64
RUN FORCE_UNSAFE_CONFIGURE=1 IGNORE_ERRORS=1 \
	make image PROFILE="tl-mr3420-v1" PACKAGES="\
		base-files \
		busybox mtd uci \
		swconfig \
		kmod-usb2 kmod-usb-ohci \
		kmod-fs-ext4 ubox block-mount kmod-scsi-core kmod-usb-storage \
		kmod-leds-gpio kmod-gpio-button-hotplug \
		kmod-ledtrig-default-on kmod-ledtrig-timer kmod-ledtrig-netdev \
		kmod-usb-ledtrig-usbport \
		uclient-fetch opkg \
#
# Исключены модули WiFi
		-libiwinfo -iwinfo -iw -iw-full -wireless-regdb -kmod-cfg80211 -kmod-mac80211 -wpad -wpad-mini -wpad-basic-wolfssl -hostapd-common \
		-kmod-ath -kmod-ath9k-common -kmod-ath9k \
#
# Включены модули ppp, pppoe
		ppp-mod-pppoe kmod-pppox kmod-pppoe kmod-ppp ppp \
#
# Исключен IPv4-odhcpd (его функции покрывает dnsmasq), оставлен только IPv6-odhcpd
		-odhcpd \
		dnsmasq odhcpd-ipv6only odhcp6c \
#
# Реквизиты для подключения модема Huawei, прошитого в Hilink
# https://gist.github.com/bjoern-r/1345e8a17f4acf41006330e688af1441
# https://global-hotspot.ru/openwrt-huawei-e3372/
# https://geek-speak.ru/forums/topic/%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-usb-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D0%B0-%D0%B2-hilink-%D0%BD%D0%B0-openwrt-19-07-3/
		kmod-usb-net kmod-usb-net-cdc-ether \
#
# Вспомогательные утилиты для проверки подключения устройств в usb (модема, HDD, flash)
		usbutils \
#
# Утилита переключения из CD-режима usb-модема для возможности доступа к microSD
		usb-modeswitch \
#
# Утилита для поддержания удаленного соединения
		autossh \
#
# Утилиты для форматирования дисков
		e2fsprogs -fdisk \
#
# Web-GUI (исключен)
		-luci \
"

WORKDIR /root/openwrt
RUN find . -name openwrt-ar71xx-tiny-tl-mr3420-v1-squashfs*.bin -type f -ls
