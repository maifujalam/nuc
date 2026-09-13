                         INTERNET
                            ▲
                            │
                       172.20.10.1 [ WiFi Router/Hotspot/ISP ]
                            │
                            │ Wi-Fi
                            ▼
                    ┌──────────────┐
                    │     NUC      │
                    │              │
                    │  wlo1        │
                    │ 172.20.10.7  │
                    │              │
                    │  vm-nat      │
                    │ 192.168.50.1 │
                    │      │       │
                    │      │       │
                    │  vm-local    │
                    │192.168.100.1 │
                    │      │       │
                    │      │       │
                    │thunderbolt0  │
                    │ 192.168.10.2 │
                    └──────┬───────┘
                           │
                    Thunderbolt
                           │
                           ▼
                    Mac 192.168.10.1 [ Thunderbolt Port on MAC ]


vm-nat:
    NUC 192.168.50.1
          │
          ▼
    VM eth0  [ NAT Network  Interface  Created by virsh ]
    192.168.50.113 [ DHCP IP Assigned by virsh ]
          │
          └──→ Internet via NAT


vm-local:
    NUC 192.168.100.1
          │
          ▼
    VM eth1  [ Local Network  Interface  Created by virsh ]
    192.168.100.10 [ Static IP Assigned by virsh ]
          │
          └──→ Mac via NUC routing

