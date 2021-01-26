FROM entware-dev:latest

WORKDIR /root/sources/wl500g

RUN git clone http://github.com/wl500g/wl500g.git . \
 && git checkout -b checked_2020-12-20 0c22b0ea4f9d37d69306d39215d2cbfb65e6b617

COPY ./mypatch.patch /root/sources/wl500g/mypatch.patch
RUN git apply mypatch.patch

WORKDIR /root/sources/wl500g/gateway

RUN make config
COPY ./menuconfig.config .config
RUN make
RUN make install

WORKDIR /root/sources/wl500g/gateway