# nuc
This project have code to configure NUC to run as a server for my home server for personal projects.

Preconfigure:
- Install Ubuntu Server 26.04 LTS on the NUC.
- Connect the NUC with thunderbolt cable to the main server (my mac).
- In MAC Static IP is configured at 192.168.10.1 with netmast 255.255.255.0 and dns 8.8.8.8
- IN NUC Static IP is configured at 192.168.10.2 with netmast 255.255.255.0 with below netplan.Stored at /etc/netplan/thunderbolt.yaml and apply with netplan apply command.
  ```yaml
  network:
    version: 2
    ethernets:
      thunderbolt0:
        addresses: [192.168.10.2/24]
        routes: 
          - to: default
            via: 192.168.10.1
        nameservers:
          addresses: [8.8.8.8,1.1.1.1]
  ```
  - MAC (192.16810.1) can ping NUC (192.168.10.2)
  - For display sharing connect with HDMI.
  - [Optional] For virtual display sharing connect with NUC, connect with dummy hdmi dongle. This is just to trick the NUC GPU to think that it has a display connected.
  - Enable gnome-display-sharing on the NUC with the following settings:
    - Desktop Sharing and Remotre Control enabled.
    - Port: 3390
    - Username: alam
    - Password: (leave blank)
  - Conenct with Windows App (form MAC) with user alam and no password.Screen sharing should work fine.

  