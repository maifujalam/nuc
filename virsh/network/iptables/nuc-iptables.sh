#!/bin/bash

# ============================================================
# ALAM-NUC - Network Forwarding Rules
# ============================================================
#
# Interfaces:
#   wlo1          : Wi-Fi
#   thunderbolt0  : Thunderbolt
#   tun0          : OpenVPN
#   vm-local      : Libvirt VM bridge
#
# Networks:
#   Wi-Fi         : 192.168.1.0/24
#   Thunderbolt   : 192.168.10.0/24
#   VM network    : 192.168.100.0/24
#   OpenVPN       : 10.8.0.0/24
#
# Purpose:
#   Allow traffic between the physical/VPN networks and
#   Kubernetes VMs connected to vm-local.
#
# NAT is intentionally NOT used for these forwarding paths.
# ============================================================

set -e

IPTABLES="/usr/sbin/iptables"

echo "Configuring NUC forwarding rules..."

# ------------------------------------------------------------
# Enable IPv4 forwarding
# ------------------------------------------------------------
sysctl -w net.ipv4.ip_forward=1


# ============================================================
# Wi-Fi <-> VM
# ============================================================

# Wi-Fi -> VM
$IPTABLES -I FORWARD 1 \
    -i wlo1 \
    -o vm-local \
    -s 192.168.1.0/24 \
    -d 192.168.100.0/24 \
    -m comment --comment "WiFi to VM network" \
    -j ACCEPT

# VM -> Wi-Fi
$IPTABLES -I FORWARD 2 \
    -i vm-local \
    -o wlo1 \
    -s 192.168.100.0/24 \
    -d 192.168.1.0/24 \
    -m comment --comment "VM network to WiFi" \
    -j ACCEPT


# ============================================================
# Thunderbolt <-> VM
# ============================================================

# Thunderbolt -> VM
$IPTABLES -I FORWARD 3 \
    -i thunderbolt0 \
    -o vm-local \
    -s 192.168.10.0/24 \
    -d 192.168.100.0/24 \
    -m comment --comment "Thunderbolt to VM network" \
    -j ACCEPT

# VM -> Thunderbolt
$IPTABLES -I FORWARD 4 \
    -i vm-local \
    -o thunderbolt0 \
    -s 192.168.100.0/24 \
    -d 192.168.10.0/24 \
    -m comment --comment "VM network to Thunderbolt" \
    -j ACCEPT


# ============================================================
# OpenVPN <-> VM
# ============================================================

# VPN -> VM
$IPTABLES -I FORWARD 5 \
    -i tun0 \
    -o vm-local \
    -j ACCEPT \
    -m comment --comment "OpenVPN to VM network"

# VM -> VPN
$IPTABLES -I FORWARD 6 \
    -i vm-local \
    -o tun0 \
    -m conntrack --ctstate ESTABLISHED,RELATED \
    -j ACCEPT \
    -m comment --comment "VM network to OpenVPN"


echo
echo "Forwarding rules configured successfully."
echo

# Display resulting rules
$IPTABLES -nvL FORWARD --line-numbers
