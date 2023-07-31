FROM openwrt/rootfs
RUN mkdir -p /var/lock

ADD VERSION /
RUN opkg update
RUN opkg install tmate
RUN opkg install mc
RUN opkg install nano
RUN opkg install lsof
RUN opkg install luci
RUN opkg install uhttpd-mod-lua

# RUN echo $'\n\
# URL="http://openwrt.org/_export/code/docs/guide-user/services/vpn/openvpn"\n\
# cat <<EOF > /openvpn-server.sh\n\
# $(uclient-fetch -O - "${URL}/server?codeblock=0")\n\
# $(uclient-fetch -O - "${URL}/server?codeblock=1")\n\
# $(uclient-fetch -O - "${URL}/server?codeblock=2")\n\
# $(uclient-fetch -O - "${URL}/server?codeblock=3")\n\
# EOF\n\
# ' > /get-openvpn-server-script.sh \
#  && chmod +x /get-openvpn-server-script.sh
# RUN sh /get-openvpn-server-script.sh
# RUN sh /openvpn-server.sh
# 
#RUN opkg install luci-app-openvpn

RUN uci set uhttpd.main.interpreter='.lua=/usr/bin/lua'
RUN uci commit uhttpd
RUN mkdir -p /var/run
USER root
CMD ["/sbin/init"]
