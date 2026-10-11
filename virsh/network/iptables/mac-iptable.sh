#!/bin/bash

DEST="192.168.100.0/24"

WIFI_IF="en0"
WIFI_GW="192.168.1.69"

TB_IF="bridge0"
TB_GW="192.168.10.2"

netstat -rn | grep -i 192.168.100
# Remove existing route if present
sudo route -n delete -net "$DEST" 2>/dev/null || true

# Prefer Thunderbolt when it is available
if ifconfig "$TB_IF" 2>/dev/null | grep -q "inet 192.168.10."; then
    echo "Thunderbolt detected - routing via $TB_GW"
    sudo route -n add -net "$DEST" "$TB_GW"
    echo "Thunderbolt route added."
    netstat -rn | grep -i 192.168.100
    exit 0
fi

# Otherwise use Wi-Fi
if ifconfig "$WIFI_IF" 2>/dev/null | grep -q "inet 192.168.1."; then
    echo "Wi-Fi detected - routing via $WIFI_GW"
    sudo route -n add -net "$DEST" "$WIFI_GW"
    echo "Wi-Fi route added."
    netstat -rn | grep -i 192.168.100
    exit 0
fi

echo "Neither Thunderbolt nor Wi-Fi route to NUC is available."
exit 1