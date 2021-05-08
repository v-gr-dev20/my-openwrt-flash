FROM openwrt-broadcom-b43-dev:latest

ARG project=helloworld
WORKDIR /root/openwrt

ENV PATH=/root/openwrt/staging_dir/host/bin:$PATH

ADD openwrt/feeds.conf .
ADD mypackages ../mypackages
ADD ${project} ../${project}

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
