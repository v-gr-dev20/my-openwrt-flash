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
" >> configdiff \
 && cp configdiff .config \
 && make defconfig
