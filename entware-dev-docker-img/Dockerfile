FROM debian:latest

RUN apt -y update \
 && apt -y install \
		nano \
		mc \
		openssh-server

# ! открываем доступ root по ssh
RUN  ( grep -e '^[ \t]*PermitRootLogin' /etc/ssh/sshd_config > /dev/null || sed -i -e '/^#[ \t]*PermitRootLogin[ \t].*$/a PermitRootLogin yes' /etc/ssh/sshd_config ) \
 && service ssh start

RUN apt -y install \
		gcc \
		cmake \
		libncurses-dev \
		zlib1g-dev \
		gawk \
		g++ \
		flex \
		bison \
		texinfo \
		git \
		wget \
		xz-utils \
		bzip2 \
		bc

RUN mkdir -p ~/downloads && cd ~/downloads \
 && wget https://github.com/wl500g/toolchain/releases/download/v3.0/hndtools-mipsel-uclibc-4.6.4-v3.0-x86_64.tar.bz2 \
 && mkdir -p /opt/brcm \
 && tar -C /opt/brcm -jxvf hndtools-mipsel-uclibc-4.6.4-v3.0-x86_64.tar.bz2 \
 && ln -sf /opt/brcm/hndtools-mipsel-uclibc-4.6.4 /opt/brcm/hndtools-mipsel-uclibc \
 && rm -rf ~/downloads

WORKDIR /
