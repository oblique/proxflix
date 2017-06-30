#!/bin/sh

ipv6_iface() {
    ip -6 route | grep '^default' | sed 's/.*dev[[:space:]]\+\([^[:space:]]\+\).*/\1/'
}

has_global_ipv6() {
    local iface="$(ipv6_iface)"
    [[ -z "$iface" ]] && return 1
    ip -6 addr show dev "$iface" | grep -q 'scope global'
}

resolver_mode=ipv4_only
has_global_ipv6 && resolver_mode=ipv6_first

cat > /tmp/sniproxy.conf << EOF
user nobody
group nobody

listener 80 {
    proto http
}

listener 443 {
    proto tls
}

resolver {
    nameserver 127.0.0.1
    mode $resolver_mode
}

table {
    .* *
}
EOF

exec sniproxy -c /tmp/sniproxy.conf -f
