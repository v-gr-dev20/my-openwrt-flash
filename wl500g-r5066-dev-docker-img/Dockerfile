FROM entware-dev:latest

RUN mkdir -p ~/downloads && cd ~/downloads \
 && wget https://github.com/wl500g/wl500g/archive/r5066.tar.gz \
 && mkdir -p ~/sources \ 
 && tar -C ~/sources -zxvf r5066.tar.gz \
 && rm -rf ~/downloads

WORKDIR /root/sources/wl500g-r5066