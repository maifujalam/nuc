                    INTERNET
                       |
                       |
                Public IP
                172.31.64.x
                       |
             +---------v---------+
             |    CLOUD VM       |
             |                   |
             | Ubuntu            |
             | OpenVPN Server    |
             |                   |
             | tun0              |
             | 10.8.0.1          |
             +---------+---------+
                       |
                 OpenVPN tunnel
                       |
                       |
             +---------v---------+
             |       NUC         |
             |                   |
             | Ubuntu            |
             | OpenVPN Client    |
             |                   |
             | tun0              |
             | 10.8.0.2          |
             +-------------------+