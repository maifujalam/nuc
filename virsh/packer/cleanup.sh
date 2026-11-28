#!/bin/bash
set -eux

sudo cloud-init clean --logs

sudo truncate -s 0 /etc/machine-id

sudo rm -f /var/lib/dbus/machine-id

sudo apt clean