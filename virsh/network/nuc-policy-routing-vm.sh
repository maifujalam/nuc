sudo ip route replace 192.168.1.0/24 dev wlo1 \
  scope link src 192.168.1.69 table 100

sudo ip route replace default via 192.168.1.1 \
  dev wlo1 table 100

sudo ip rule add priority 100 from 192.168.50.0/24 lookup 100

ip rule show
ip route show table 100
ip route get 8.8.8.8 from 192.168.50.10


sudo iptables -nvL --line-number
