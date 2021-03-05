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
CONFIG_PACKAGE_kmod-ledtrig-default-on=y		\n\
CONFIG_PACKAGE_kmod-ledtrig-timer=y				\n\
CONFIG_PACKAGE_kmod-ledtrig-netdev=y			\n\
CONFIG_PACKAGE_usb-modeswitch=y					\n\
CONFIG_PACKAGE_kmod-usb-net=y					\n\
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y			\n\
CONFIG_PACKAGE_usbutils=y						\n\
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5

WORKDIR /root/openwrt/build_dir/target-mipsel_mips32_musl/openwrt-imagebuilder-brcm47xx-legacy.Linux-x86_64
RUN FORCE_UNSAFE_CONFIGURE=1 IGNORE_ERRORS=1 \
	make image PROFILE="Broadcom-b43" PACKAGES="\
		base-files \
		busybox mtd uci nvram \
		swconfig \
		kmod-usb2 kmod-usb-ohci \
		kmod-fs-ext4 ubox block-mount kmod-scsi-core kmod-usb-storage \
		kmod-leds-gpio kmod-gpio-button-hotplug \
		kmod-ledtrig-default-on kmod-ledtrig-timer kmod-ledtrig-netdev \
		-libiwinfo -iwinfo -iw-full -b43legacy-firmware -wireless-regdb -kmod-cfg80211 -kmod-mac80211 -kmod-b43 -kmod-b43legacy -wpad -wpad-mini -wpad-basic-wolfssl -hostapd-common \
		-ppp-mod-pppoe -kmod-pppox -kmod-pppoe -kmod-ppp -ppp \
		uclient-fetch opkg \
		-odhcpd \
		dnsmasq odhcpd-ipv6only odhcp6c \
#
# https://gist.github.com/bjoern-r/1345e8a17f4acf41006330e688af1441
# https://global-hotspot.ru/openwrt-huawei-e3372/
# https://geek-speak.ru/forums/topic/%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0-usb-%D0%BC%D0%BE%D0%B4%D0%B5%D0%BC%D0%B0-%D0%B2-hilink-%D0%BD%D0%B0-openwrt-19-07-3/
#
# Реквизиты для подключения модема Huawei, прошитого в Hilink
		kmod-usb-net kmod-usb-net-cdc-ether \
#
# Вспомогательные утилиты для проверки подключения устройств в usb (модема, HDD, flash)
		usbutils \
		usb-modeswitch \
"

WORKDIR /root/openwrt
RUN find . -name openwrt-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx -type f -ls
