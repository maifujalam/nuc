1. List all domains: virsh list --all
2. List all the details of a domain: virsh dominfo <domain_name>
3. Start a domain: virsh start <domain_name>
4. Stop a domain: virsh shutdown <domain_name>
5. Force stop a domain: virsh destroy <domain_name>


Expand disk of a domain:
1. List all the disks of a domain:virsh list --all
2. Domain disk details: virsh domblklist worker-3_worker-3
3. List disk pool: virsh pool-list --all
4. List all disks in default pool: virsh vol-list default --details
5. Expand disk of a domain: virsh vol-resize <disk_name> <new_size> --pool default
   Example:  virsh vol-resize  worker-3_worker-3-vdb.qcow2 20G --pool default


Force format a disk:
1. List all the disks of a domain:virsh list --all
2. Domain disk details: virsh domblklist worker-3_worker-3
3. List disk pool: virsh pool-list --all
4. List all disks in default pool: virsh vol-list default --details
5. Force format a disk of a domain: virsh vol-resize <disk_name>