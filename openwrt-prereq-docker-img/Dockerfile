FROM debian:latest

RUN apt -y update \
 && apt -y install \
		nano \
		binwalk \
		squashfs-tools \
		mc \
		openssh-server

# ! открываем доступ root по ssh
RUN  ( grep -e '^[ \t]*PermitRootLogin' /etc/ssh/sshd_config > /dev/null || sed -i -e '/^#[ \t]*PermitRootLogin[ \t].*$/a PermitRootLogin yes' /etc/ssh/sshd_config ) \
 && service ssh start


RUN apt -y install \
		build-essential \
		ccache \
		ecj \
		fastjar \
		file \
		g++ \
		gawk \
		gettext \
		git \
		java-propose-classpath \
		libelf-dev \
		libncurses5-dev \
		libncursesw5-dev \
		libssl-dev \
		python \
		python2.7-dev \
		python3 \
		unzip \
		wget \
		python3-distutils \
		python3-setuptools \
		rsync \
		subversion \
		swig \
		time \
		xsltproc \
		zlib1g-dev

