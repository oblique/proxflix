FROM alpine

RUN apk add --no-cache supervisor bind-tools iptables sniproxy dnsmasq

ADD instl /usr/local/bin/
RUN mkdir -p /opt/proxflix
ADD dnsmasq.sh sniproxy.sh domains proxflix /opt/proxflix/

ADD services.ini /etc/supervisor.d/
ADD my_init /
CMD ["/my_init"]
