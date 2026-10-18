grdctl rdp set-credentials
grdctl rdp enable
grdctl rdp disable-view-only
systemctl --user restart gnome-remote-desktop
grdctl status --show-credentials
sudo ss -lntp | grep -E ':(3389|3390)\b'
sudo tcpdump -ni wlo1 port 3390


sudo tcpdump -ni thunderbolt0 port 3390
journalctl --user -u gnome-remote-desktop --since "10 minutes ago"
sudo tcpdump -ni thunderbolt0 -s 0 -w /tmp/rdp-3390.pcap 'host 172.16.0.1 and tcp port 3390'


grdctl rdp enable
grdctl rdp set-credentials 'alam' ''
grdctl rdp set-tls-cert ~/rdp-tls.crt
grdctl rdp set-tls-key ~/rdp-tls.key
systemctl --user restart gnome-remote-desktop
grdctl status --show-credentials

systemctl --user status gnome-remote-desktop --no-pager -l


alam@ALAM-NUC:~$ grdctl status
Overall:
	Unit status: active
RDP:
	Status: enabled
	Port: 3389
	Authentication methods: credentials
	TLS certificate: /home/alam/rdp-tls.crt
	TLS fingerprint: e5:f4:ad:42:31:e3:92:83:b1:78:3a:70:53:e0:9b:3a:1b:4b:c6:fa:27:5f:ff:6d:f9:93:f4:b8:01:39:2b:ff
	TLS key: /home/alam/rdp-tls.key
	Kerberos keytab:
	View-only: no
	Negotiate port: yes
	Username: (hidden)
	Password: (empty)
alam@ALAM-NUC:~$


sudo grdctl --system rdp set-credentials 'alam' 'alam'

sudo vi /etc/gdm3/custom.conf

sudo journalctl --since "5 min ago" --no-pager | grep -iE "gnome-remote|gdm|mutter|gnome-shell|pipewire|greeter|handover" | tail -80

Set keyring password:
echo -n "alam" | gnome-keyring-daemon --replace --unlock
sdl-freerdp /v:192.168.1.69 /u:alam /p:'alam' /cert:ignore /size:1920x1080
