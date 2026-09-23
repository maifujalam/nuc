# Access K8S(Private) Cluster from internet:-

Prerequities:-
- K8S Cluster with private network.
- Bastion host on AWS with dns (app.example.com) resolves to the VM pulic IP.
- Bastion VM is having vpn tunnel to the NUC.
- NUC is having a private network with K8S cluster and the bastion host is able to reach the NUC private network.
- Bastion and NUC have ipv4 forwarding enabled.

## On Bastion VM:

Make IPV forwarding from private ip interface to the tunnel interface.
a. iptables -nvL --line-number
b. Add DNAT rule to forward packets: 
 Bastion (ens5 -> tun0)# iptables -t nat -A PREROUTING -i ens5 -p tcp --dport 6443 -j DNAT --to-destination <NUC_PRIVATE_IP>:6443
   
c. Verify the forwarded packet: iptables -t nat -nvL --line-number
d.  tcpdump -ni tun0 tcp port 32687
e. Make SNAT rule to allow return packets from NUC to Bastion: 
    # iptables -t nat -A POSTROUTING -o tun0 -p tcp -d 10.8.0.2 --dport 32687 -j SNAT --to-source 10.8.0.1
    t: type is nat
    A: Append to POSTROUTING chain
    o: Match the packets leaving the outgoing/output interface is tun0
    p: Match the packets with protocol tcp
    d: Match the packets with destination IP 10.8.0.2
    dport: Match the packets with destination port 32687
    -j SNAT --to-source <ip> : Replace the source IP address of the packet with the specified IP address.

f. Also make the post routing for MASQUAD to provide the internet access to the NUC private network.
    iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
g. Save the iptables rules to persist after reboot:
    - For Ubuntu/Debian: sudo apt-get install iptables-persistent
    - Save the rules: iptables-save > /etc/iptables/rules.v4
    - For loading the rules: iptables-restore < /etc/iptables/rules.v4
h. also make sure the filter table is allowing the traffic from the bastion to the NUC private network and vide versa.
   $ iptables -nvL --line-number  [ it should by default accept all]

## On NUC Host:
a. Make the NUC NAT trafic from the bastion host(tun0) to the K8S cluster private network(vm-local)
   a. DNAT from tunnel to vm-local: iptables -t nat -A PREROUTING -i tun0 -p tcp --dport 32687 -j DNAT --to-destination 192.168.100.10:32687
   b. SNAT from vm-local to tunnel: iptables -t nat -A POSTROUTING -o vm-local -p tcp -d 192.168.100.10 --dport 32687 -j SNAT --to-source 192.168.100.1

b. Make the allow in the filter table to allow the traffic from the bastion host(tun0) to the K8S cluster private network(vm-local) and vice versa.
   a. iptables -A FORWARD -i tun0 -o vm-local -p tcp -j ACCEPT
   b. iptables -A FORWARD -i vm-local -o tun0 -p tcp -j ACCEPT
c. Save the iptables rules to persist after reboot:
    - For Ubuntu/Debian: sudo apt-get install iptables-persistent
    - Save the rules: iptables-save > /etc/iptables/rules.v4
    - For loading the rules: iptables-restore < /etc/iptables/rules.v4
d. also make sure the filter table is allowing the traffic from the bastion to the NUC private network and vide versa.
   $ iptables -nvL --line-number  [ it should by default accept all]