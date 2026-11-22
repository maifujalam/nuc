Feature	RBD (Block)	CephFS (Filesystem)	NFS	Ceph Bucket (Object)
StorageClass	ceph-block	ceph-filesystem	ceph-nfs	ceph-bucket
Interface	Block Device	POSIX Filesystem	NFS Protocol	S3 API
Access Mode	RWO	RWX	RWX	HTTP/S3
Mounted as Disk	✅	✅	✅	❌
Mounted as Filesystem	❌	✅	✅	❌
Multiple Writers	❌	✅	✅	✅
Best Performance	⭐⭐⭐⭐⭐	⭐⭐⭐⭐	⭐⭐	⭐⭐⭐⭐
Kubernetes PVC	✅	✅	✅	❌
External Access	Limited	Limited	Yes	Yes
Huge Scale	Good	Good	Moderate	Excellent