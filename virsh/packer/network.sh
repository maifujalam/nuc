rm -f /etc/netplan/50-cloud-init.yaml
sudo tee /etc/netplan/00-installer-config.yaml >/dev/null <<'EOF'
network:
  version: 2
  ethernets:
    ens0:
      match:
        name: "ens5"
      set-name: ens0
      dhcp4: true

    ens1:
      match:
        name: "ens6"
      set-name: ens1
      dhcp4: true
EOF
sudo netplan generate
sudo netplan apply