grdctl rdp set-credentials
grdctl rdp enable
grdctl rdp disable-view-only
systemctl --user restart gnome-remote-desktop
grdctl status
sudo ss -lntp | grep -E ':(3389|3390)\b'
sudo tcpdump -ni wlo1 port 3390