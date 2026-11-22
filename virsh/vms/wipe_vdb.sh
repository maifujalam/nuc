#!/usr/bin/env bash
set -euo pipefail

DOMAINS=(worker-1_worker-1 worker-2_worker-2 worker-3_worker-3)
SIZE=15G
TARGET=vdb

echo "This will WIPE the $TARGET disk (all data) on: ${DOMAINS[*]}"
read -rp "Type 'yes' to continue: " ans
[ "$ans" = "yes" ] || { echo "Aborted."; exit 1; }

for dom in "${DOMAINS[@]}"; do
  echo "=== $dom ==="

  # Path of vdb for this domain
  disk=$(virsh domblklist --domain "$dom" | awk -v t="$TARGET" '$1==t {print $2}')
  if [[ -z "$disk" || "$disk" != *-vdb.qcow2 ]]; then
    echo "Unexpected or missing $TARGET path for $dom: '$disk' - skipping"
    continue
  fi
  echo "Disk: $disk"

  # Shut down (graceful, then forced after 60s)
  if [ "$(virsh domstate "$dom")" != "shut off" ]; then
    virsh shutdown "$dom" >/dev/null || true
    for _ in $(seq 1 30); do
      [ "$(virsh domstate "$dom")" = "shut off" ] && break
      sleep 2
    done
    if [ "$(virsh domstate "$dom")" != "shut off" ]; then
      echo "Graceful shutdown timed out, forcing off"
      virsh destroy "$dom" >/dev/null
    fi
  fi

  # Recreate the image, preserving owner and mode
  owner=$(sudo stat -c '%u:%g' "$disk")
  mode=$(sudo stat -c '%a' "$disk")
  sudo qemu-img create -f qcow2 "$disk" "$SIZE"
  sudo chown "$owner" "$disk"
  sudo chmod "$mode" "$disk"

  # Start it again
  virsh start "$dom"
done

echo "Done. Verify each node with: sudo wipefs /dev/vdb"