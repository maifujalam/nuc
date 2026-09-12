#!/usr/bin/env bash
# This script creates a virtual network using virsh.
sudo virsh net-define vm-nat.xml
sudo virsh net-autostart vm-nat
sudo virsh net-start vm-nat

sudo virsh net-define vm-local.xml
sudo virsh net-autostart vm-local
sudo virsh net-start vm-local

virsh net-list --all