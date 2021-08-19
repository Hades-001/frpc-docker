FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ARG TAG

WORKDIR /root
RUN set -ex && \
	apk add --update git build-base && \
	git clone https://github.com/fatedier/frp.git frp && \
	cd ./frp && \
	git fetch --all --tags && \
	git checkout tags/${TAG} && \
	make frpc

FROM --platform=${TARGETPLATFORM} alpine:latest
COPY --from=builder /root/frp/bin/frpc /usr/bin/

RUN apk add --no-cache ca-certificates su-exec

RUN mkdir -p /etc/frpc

VOLUME ["/etc/frpc"]

WORKDIR /etc/frpc

ENV PUID=1000 PGID=1000 HOME=/etc/frpc

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

CMD /usr/bin/frpc