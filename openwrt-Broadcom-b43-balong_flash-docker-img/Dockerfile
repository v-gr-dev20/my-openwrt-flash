FROM openwrt-broadcom-b43-dev:latest

ARG project=balong_flash
WORKDIR /root/openwrt

ENV PATH=/root/openwrt/staging_dir/host/bin:$PATH

ADD openwrt/feeds.conf .
ADD mypackages ../mypackages

RUN mkdir -p /root/${project} && cd /root/${project} \
 && git clone https://github.com/forth32/balongflash.git . \
 && sed '/^balong_flash: /,+3 {		\
			# замена на $(CC) вместо @gcc
			s/^\t@gcc /\t$(CC) /;	\
			# прячем неработающую строку, которая должна была инкрементировать значение в файле build
			s/^.*>build\s*$/# &/;	\
		}' -i Makefile

WORKDIR /root/openwrt

# Prebuild
RUN ./scripts/feeds update mypackages \
 && ./scripts/feeds install -a -p mypackages \
 && echo "\
CONFIG_FEED_mypackages=y						\n\
CONFIG_PACKAGE_${project}=y						\n\
" >> configdiff \
 && cp configdiff .config \
 && make defconfig

# Build
RUN FORCE_UNSAFE_CONFIGURE=1 \
	make -j5
