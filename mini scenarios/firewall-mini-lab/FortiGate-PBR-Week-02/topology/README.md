# Topology and cabling

| From | To | Link |
|---|---|---|
| PC-PBR NIC | SW-LAN Gi0/2 | LAN access VLAN 10 |
| PC-DEFAULT NIC | SW-LAN Gi0/3 | LAN access VLAN 10 |
| SW-LAN Gi0/1 | FGT-HQ port1 | LAN 10.10.10.0/24 |
| FGT-HQ port2 | R1-ISP-A Gi0/0 | WAN1 203.0.113.0/30 |
| FGT-HQ port3 | R2-ISP-B Gi0/0 | WAN2 198.51.100.0/30 |
| R1-ISP-A Gi0/1 | R3-CORE Gi0/0 | Transit A 10.0.1.0/30 |
| R2-ISP-B Gi0/1 | R3-CORE Gi0/1 | Transit B 10.0.2.0/30 |

Server-A is R3-CORE Loopback0 (192.0.2.10/32), the exact PBR destination. Server-B is Loopback1 (192.0.2.20/32), a nonmatching destination used to prove that normal routing still uses WAN1.

Use the PNG for documents, SVG for editing, and DOT as a Graphviz source if Graphviz is installed.
