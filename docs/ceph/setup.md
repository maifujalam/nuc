1. ceph -s
2. ceph health detail

===== Storage Distribustion =====
1. Ceph Block Storage (RBD): 0.6  Used for RWO PVCs like:- Elastic Seach.
2. Ceph File System (CephFS): 0.2  Used for RWX PVCs like:- NextCloud, MinIO, etc.
3. Ceph Object Storage (RGW): 0.1  Used for S3 compatible storage like:- MinIO, NextCloud, etc.
4. Ceph NFS: 0.1  Used for NFS storage like:- Kubernetes NFS, etc.