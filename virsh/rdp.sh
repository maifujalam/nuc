grdctl rdp set-credentials
grdctl rdp enable
grdctl rdp disable-view-only
systemctl --user restart gnome-remote-desktop
grdctl status
sudo ss -lntp | grep -E ':(3389|3390)\b'
sudo tcpdump -ni wlo1 port 3390


sudo tcpdump -ni thunderbolt0 port 3390
journalctl --user -u gnome-remote-desktop --since "10 minutes ago"
sudo tcpdump -ni thunderbolt0 -s 0 -w /tmp/rdp-3390.pcap 'host 172.16.0.1 and tcp port 3390'
