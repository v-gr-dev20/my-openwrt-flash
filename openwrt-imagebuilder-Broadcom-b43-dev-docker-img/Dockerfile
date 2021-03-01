FROM openwrt-prereq:latest

WORKDIR /root/sources/openwrt

RUN wget "https://downloads.openwrt.org/releases/19.07.7/targets/brcm47xx/legacy/openwrt-imagebuilder-19.07.7-brcm47xx-legacy.Linux-x86_64.tar.xz" \
 && tar -xf openwrt-imagebuilder-19.07.7-brcm47xx-legacy.Linux-x86_64.tar.xz \
 && rm openwrt-imagebuilder-19.07.7-brcm47xx-legacy.Linux-x86_64.tar.xz \
 && cd openwrt-imagebuilder-19.07.7-brcm47xx-legacy.Linux-x86_64 \
 && make image PROFILE="Broadcom-b43" PACKAGES="base-files libc libgcc busybox kmod-usb2 kmod-usb-ohci kmod-usb-uhci kmod-usb-storage kmod-fs-ext4 ubox block-mount kmod-scsi-core mtd uci opkg netifd fstools swconfig wpad-mini nvram -otrx kmod-leds-gpio kmod-gpio-button-hotplug kmod-ledtrig-default-on kmod-ledtrig-timer kmod-ledtrig-netdev dnsmasq iptables -ip6tables ppp ppp-mod-pppoe kmod-nf-nathelper firewall odhcpd odhcp6c -odhcpd-ipv6only -libiwinfo20181126 -iwinfo -iw-full -b43legacy-firmware -wireless-regdb -kmod-cfg80211 -kmod-mac80211 -kmod-b43 -kmod-b43legacy" \
 && find . -name openwrt-19.07.7-brcm47xx-legacy-asus-wl-500gp-v2-squashfs.trx -type f -ls
