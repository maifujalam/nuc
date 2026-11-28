1. Download cloud image: 
wget https://cloud-images.ubuntu.com/minimal/releases/resolute/release/ubuntu-26.04-minimal-cloudimg-amd64v3.img

2. bake image: alam@ALAM-NUC:~
qemu-img create -f qcow2 -F qcow2 -b ubuntu-26.04-minimal-cloudimg-amd64v3.img k8s-nuc.qcow2 20G

Formatting 'k8s-nuc.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=21474836480 backing_file=ubuntu-26.04-minimal-cloudimg-amd64v3.img backing_fmt=qcow2 lazy_refcounts=off refcount_bits=16

3. Resize image:
qemu-img resize k8s-nuc.qcow2 20G

4. Check image info:
qemu-img info k8s-nuc.qcow2