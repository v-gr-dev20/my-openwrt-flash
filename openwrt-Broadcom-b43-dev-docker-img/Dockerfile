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
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5

WORKDIR /root/openwrt
RUN find . -name openwrt-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx -type f -ls
