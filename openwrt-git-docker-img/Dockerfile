FROM openwrt-prereq:latest

WORKDIR /root/openwrt
RUN git clone https://git.openwrt.org/openwrt/openwrt.git . \
 && git checkout -b actual v19.07.7 \
 && make distclean

WORKDIR /root/openwrt
RUN ./scripts/feeds update -a \
 && ./scripts/feeds install -a
