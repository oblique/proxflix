#!/bin/sh

to_upper() {
    echo "$@" | tr 'a-z' 'A-Z'
}

cache_server=0
[ "$1" == "--cache" ] && cache_server=1

if [ "$cache_server" -eq 1 ]; then
    conf=/tmp/dnsmasq-cache.conf
    resolv=/tmp/dnsmasq-cache.resolv
else
    conf=/tmp/dnsmasq.conf
    resolv=/tmp/dnsmasq.resolv
fi

rm -f $conf $resolve

cat > $conf << EOF
keep-in-foreground
no-hosts
resolv-file=$resolv
EOF

if [ "$cache_server" -eq 1 ]; then
    echo "port=5399" >> $conf
    iptables -w -t nat -A OUTPUT -s 127.0.0.1 -p udp -m udp --dport 53 -j REDIRECT --to 5399
    iptables -w -t nat -A OUTPUT -s 127.0.0.1 -p tcp -m tcp --dport 53 -j REDIRECT --to 5399
else
    EXT_IP=${EXT_IP:-$(dig +short myip.opendns.com @resolver1.opendns.com 2> /dev/null)}
    for x in $(cat /opt/proxflix/domains); do
        echo "address=/$x/$EXT_IP" >> $conf
    done
fi

DNS_SERVER="${DNS_SERVER:-8.8.8.8,8.8.4.4}"
DNS_SERVER="${DNS_SERVER//,/ }"

for x in $DNS_SERVER; do
    echo "nameserver $x" >> $resolv
done

exec dnsmasq -C $conf
