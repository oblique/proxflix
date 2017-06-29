#!/bin/sh

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
    mode ipv4_only
}

table {
    .* *
}
EOF

exec sniproxy -c /tmp/sniproxy.conf -f
