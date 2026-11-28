1. sudo du -h --max-depth=1 /var/ | sort -hr
2. sudo du -h --max-depth=1 /var/lib/docker/ | sort -hr

sudo qemu-img info /var/lib/libvirt/images/worker-3_worker-3.img
sudo ls -althr /var/lib/libvirt/images/