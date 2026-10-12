# GLBP Lab — Addressing Table

## User LAN and GLBP group

| Device | Interface | IPv4 address | Purpose |
|---|---|---:|---|
| PC1 | NIC | `192.168.10.11/24` | Test client 1 |
| PC2 | NIC | `192.168.10.12/24` | Test client 2 |
| R1 | G0/0 | `192.168.10.2/24` | Preferred GLBP Active Virtual Gateway (AVG) |
| R2 | G0/0 | `192.168.10.3/24` | Second GLBP member; can become AVG if R1 fails |
| Both routers | GLBP group 10 | `192.168.10.1` | Shared virtual default gateway configured on PCs |
| SW1 | — | — | Layer 2 switch; no management IP required for this exercise |

## Upstream links

| Device | Interface | IPv4 address | Connected to |
|---|---|---:|---|
| R1 | G0/1 | `10.0.12.1/30` | R3 G0/0 |
| R3 | G0/0 | `10.0.12.2/30` | R1 G0/1 |
| R2 | G0/1 | `10.0.23.1/30` | R3 G0/1 |
| R3 | G0/1 | `10.0.23.2/30` | R2 G0/1 |
| R3 | Loopback0 | `203.0.113.1/32` | Simulated external test destination |

**PC settings:** subnet mask `255.255.255.0`; default gateway `192.168.10.1` on both PCs. Use the exact interface names available on your router image if they differ from `GigabitEthernet0/0` and `GigabitEthernet0/1`.
