sudo bash <<'ROOT'
# set -e

OUT=/home/ubuntu/iphone16.ovpn
CA=/etc/openvpn/server/ca.crt
CERT=/home/ubuntu/openvpn-ca/pki/issued/iphone16.crt
KEY=/home/ubuntu/openvpn-ca/pki/private/iphone16.key
TLS=/etc/openvpn/server/ta.key

test -s "$CA"
test -s "$CERT"
test -s "$KEY"
test -s "$TLS"
test ! -e "$OUT" || {
    echo "STOP: $OUT already exists; refusing to overwrite it."
    exit 1
}

{
cat <<'EOF'
client
dev tun
proto udp
remote 13.207.12.184 1194
nobind
persist-key
persist-tun
remote-cert-tls server
auth-nocache
verb 3

route 192.168.100.0 255.255.255.0

<ca>
EOF
cat "$CA"
cat <<'EOF'
</ca>
<cert>
EOF
cat "$CERT"
cat <<'EOF'
</cert>
<key>
EOF
cat "$KEY"
cat <<'EOF'
</key>
<tls-crypt>
EOF
cat "$TLS"
cat <<'EOF'
</tls-crypt>
EOF
} > "$OUT"

chown ubuntu:ubuntu "$OUT"
chmod 600 "$OUT"

echo "Created $OUT"
echo "Permissions:"
ls -l "$OUT"
echo "Profile sections:"
grep -E '^<(ca|cert|key|tls-crypt)>$|^</(ca|cert|key|tls-crypt)>$' "$OUT"
ROOT