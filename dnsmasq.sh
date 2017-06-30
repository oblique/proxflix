#!/bin/sh

ipv6_iface() {
    ip -6 route | grep '^default' | sed 's/.*dev[[:space:]]\+\([^[:space:]]\+\).*/\1/'
}

has_global_ipv6() {
    local x

    for x in $(ipv6_iface); do
        if ip -6 addr show dev "$x" | grep -q 'scope global'; then
            return 0
        fi
    done

    return 1
}

get_ext_ip() {
    dig +short myip.opendns.com @resolver1.opendns.com 2> /dev/null
}

get_ext_ipv6() {
    if has_global_ipv6; then
        dig AAAA +short myip.opendns.com @2620:0:ccc::2 2> /dev/null
    fi
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
    EXT_IP=${EXT_IP:-$(get_ext_ip)}
    EXT_IPV6=${EXT_IPV6:-$(get_ext_ipv6)}

    for x in $(cat /opt/proxflix/domains); do
        [[ -n "$EXT_IP" ]] && echo "address=/$x/$EXT_IP" >> $conf
        [[ -n "$EXT_IPV6" ]] && echo "address=/$x/$EXT_IPV6" >> $conf
    done
fi

DNS_SERVER="${DNS_SERVER:-8.8.8.8,8.8.4.4}"
DNS_SERVER="${DNS_SERVER//,/ }"

for x in $DNS_SERVER; do
    echo "nameserver $x" >> $resolv
done

exec dnsmasq -C $conf
