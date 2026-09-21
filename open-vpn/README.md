1. sudo apt install -y openvpn easy-rsa
2. mkdir -p ~/openvpn-ca
   cd ~/openvpn-ca
3. Seatup PKI: easyrsa init-pki
4. Setup CA:
   a. easyrsa build-ca
   b. enter pass
   c. enter common name: server
5. Create VPN server certificate and key:
   a. easyrsa build-server-full server nopass
   b. enter yes
   c. enter password created in step 4b.
   d. You will get as beow:
       Certificate created at:
       * /home/ubuntu/openvpn-ca/pki/issued/server.crt
    Also, Key cretaed at:
        /home/ubuntu/openvpn-ca/pki/private/server.key 
7. Generate Diffie-Hellman parameters: easyrsa gen-dh  [ may take 1+ mins] and ta key: openvpn --genkey secret ta.key
8. Generate HMAC signature to strengthen the server's TLS integrity verification capabilities: sudo openvpn --genkey secret /etc/openvpn/ta.key
9. Copy the server certificate, key, and Diffie-Hellman parameters to the OpenVPN directory:
   a. sudo mkdir -p /etc/openvpn/server
   b. sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt /etc/openvpn
   c. sudo cp pki/dh.pem /etc/openvpn
   d. sudo cp ta.key /etc/openvpn
10. Create a server configuration file with below conditions: sudo vi /etc/openvpn/server.conf

port 1194
proto udp
dev tun

user nobody
group nogroup

topology subnet

server 10.8.0.0 255.255.255.0

push "route 10.8.0.0 255.255.255.0"

ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem

tls-crypt /etc/openvpn/ta.key

keepalive 10 120

persist-key
persist-tun

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
data-ciphers-fallback AES-256-GCM

status /var/log/openvpn/status.log
log-append /var/log/openvpn/server.log

verb 3

explicit-exit-notify 1

11. Enable IP forwarding: sudo vi /etc/sysctl.conf
   a. Uncomment the line: net.ipv4.ip_forward=1
   b. Apply the changes: sudo sysctl -p
   c. Verify: cat /proc/sys/net/ipv4/ip_forward
12. Copy the openvpn server configuration file to the systemd directory:
 sudo cp /etc/openvpn/server.conf /etc/openvpn/server.conf
 sudo chmod 600 /etc/openvpn/server.conf
13. Restart the OpenVPN service and enable it to start on boot:
    sudo systemctl daemon-reload
   a. sudo systemctl start openvpn-server@server
   b. sudo systemctl enable openvpn-server@server
   c. Check the status: sudo systemctl status openvpn-server@server
14. Verify:
   a. ifconfig tun0
   b. sudo netstat -nlp | grep -i vpn

============== Client Configuration ==============
15. Create a client configuration file:
   a. cd ~/openvpn-ca
   b. Create client certificate and key: easyrsa build-client-full nuc-client nopass
   c. Enter yes and password created in step 4b.
   d. You will get as beow:
       Certificate created at:
       * /home/ubuntu/openvpn-ca/pki/issued/nuc-client.crt
    Also, Key cretaed at:
        /home/ubuntu/openvpn-ca/pki/private/nuc-client.key
16. Prepare the client directory and copy the necessary files:
   a.  mkdir -p ~/nuc-openvpn-client
   b. cp pki/ca.crt ~/nuc-openvpn-client/
      cp pki/issued/nuc-client.crt ~/nuc-openvpn-client/
      cp pki/private/nuc-client.key ~/nuc-openvpn-client/
      sudo cp /etc/openvpn/server/ta.key ~/nuc-openvpn-client/
   c. Verify 4 files are present in ~/nuc-openvpn-client directory: ls -l ~/nuc-openvpn-client
17. Create openvpn client configuration file: vi ~/nuc-openvpn-client/nuc-client.ovpn

client

dev tun
proto udp

remote YOUR_CLOUD_VM_PUBLIC_IP 1194

resolv-retry infinite
nobind

persist-key
persist-tun

remote-cert-tls server

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
data-ciphers-fallback AES-256-GCM

verb 3

<ca>
PASTE_CA_CERT_HERE
</ca>

<cert>
PASTE_NUC_CLIENT_CERT_HERE
</cert>

<key>
PASTE_NUC_CLIENT_KEY_HERE
</key>

<tls-crypt>
PASTE_TA_KEY_HERE
</tls-crypt>

18. Optional: Automaticcally create client configuration file with embedded certificates and keys:
    a. cd ~/nuc-openvpn-client;export YOUR_CLOUD_VM_PUBLIC_IP=YOUR_CLOUD_VM_PUBLIC_IP
    b. Create a script: 

# 1. Set your server's public IP address here before running:
export YOUR_CLOUD_VM_PUBLIC_IP=$NUC_PUBLIC_IP

# 2. Generate the configuration file:
cat > nuc.conf <<EOF
client
dev tun
proto udp

remote $YOUR_CLOUD_VM_PUBLIC_IP 1194

resolv-retry infinite
nobind

persist-key
persist-tun

remote-cert-tls server

data-ciphers AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305
data-ciphers-fallback AES-256-GCM

key-direction 1
verb 3

<ca>
$(cat ca.crt)
</ca>

<cert>
$(cat nuc-client.crt)
</cert>

<key>
$(cat nuc-client.key)
</key>

<tls-crypt>
$(cat ta.key)
</tls-crypt>
EOF

19. Transfer the client configuration file to your local machine using scp:
   a. SSH to nuc and pull using scp: scp ubuntu@$BASTION_PUBLIC_IP:/home/ubuntu/nuc-openvpn-client/nuc.conf /home/alam/
   b. Copy the file to the openvpn gui client and connect to the VPN server.
      sudo cp /home/alam/nuc.conf /var/snap/simple-openvpn-client-gui/common/client.conf
20. Connect to the VPN server using the OpenVPN GUI client and verify the connection.
21. Verfy:
   a. sudo systemctl status openvpn-client@nuc.service --no-pager -l
   b. Verify ICMP Packet leaves the cleint: In one terminal,  sudo tcpdump -ni any 'icmp and host 10.8.0.1' and 
       in another terminal, ping.
22. For openvpn cli client:

a.  sudo mv /etc/openvpn/client/nuc.ovpn  /etc/openvpn/client/nuc.conf
b.  sudo systemctl start openvpn-client@nuc
c.  sudo systemctl enable openvpn-client@nuc
d.  sudo systemctl status openvpn-client@nuc --no-pager -l