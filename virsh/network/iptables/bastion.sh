# DNAT all inbound traffic → NUC
sudo iptables -t nat -A PREROUTING -i ens5 -j DNAT --to-destination 10.8.0.2

# Allow forwarding Bastion → NUC
sudo iptables -A FORWARD -i ens5 -o tun0 -j ACCEPT

# Allow return traffic NUC → Bastion
sudo iptables -A FORWARD -i tun0 -o ens5 -m state --state ESTABLISHED,RELATED -j ACCEPT

# SNAT/MASQUERADE all outbound traffic on tun0
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE


sudo ip route add 192.168.100.0/24 via 10.8.0.2 dev tun0

