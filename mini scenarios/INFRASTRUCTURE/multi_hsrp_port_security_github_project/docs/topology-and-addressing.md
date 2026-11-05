# Topology and addressing plan

See `../diagrams/topology.png`.

## Assumed physical links

| Link | Side A | Side B | Addressing / mode |
|---|---|---|---|
| R1–CSW1 | R1 G0/0 | CSW1 Gi1/0 | R1 `10.0.1.1/30`; CSW1 `10.0.1.2/30`, routed |
| R1–CSW2 | R1 G0/1 | CSW2 Gi1/0 | R1 `10.0.2.1/30`; CSW2 `10.0.2.2/30`, routed |
| R2–CSW1 | R2 G0/0 | CSW1 Gi1/1 | R2 `10.0.3.1/30`; CSW1 `10.0.3.2/30`, routed |
| R2–CSW2 | R2 G0/1 | CSW2 Gi1/1 | R2 `10.0.4.1/30`; CSW2 `10.0.4.2/30`, routed |
| CSW1–CSW2 | CSW1 Gi1/2 | CSW2 Gi1/2 | `10.0.0.1/30` and `10.0.0.2/30`, routed |
| CSW1–DSW1 | CSW1 Gi1/3 | DSW1 Gi1/0 | `.1` / `.2` in `10.0.11.0/30`, routed |
| CSW1–DSW2 | CSW1 Gi1/4 | DSW2 Gi1/0 | `.1` / `.2` in `10.0.12.0/30`, routed |
| CSW2–DSW1 | CSW2 Gi1/3 | DSW1 Gi1/1 | `.1` / `.2` in `10.0.21.0/30`, routed |
| CSW2–DSW2 | CSW2 Gi1/4 | DSW2 Gi1/1 | `.1` / `.2` in `10.0.22.0/30`, routed |
| DSW1–DSW2 | Gi1/2 each | Gi1/2 each | 802.1Q trunk; VLANs 10,20,30,40,999 |
| DSW1–ASW1 | DSW1 Gi1/3 | ASW1 Gi0/1 | 802.1Q trunk |
| DSW2–ASW1 | DSW2 Gi1/3 | ASW1 Gi0/2 | 802.1Q trunk |
| DSW1–ASW2 | DSW1 Gi1/4 | ASW2 Gi0/1 | 802.1Q trunk |
| DSW2–ASW2 | DSW2 Gi1/4 | ASW2 Gi0/2 | 802.1Q trunk |

## Client VLANs and gateway addresses

| VLAN | Subnet | DSW1 SVI | DSW2 SVI | HSRP VIP | Preferred active |
|---|---|---|---|---|---|
| 10 | `192.168.10.0/24` | `192.168.10.2` | `192.168.10.3` | `192.168.10.1` | DSW1 |
| 20 | `192.168.20.0/24` | `192.168.20.2` | `192.168.20.3` | `192.168.20.1` | DSW2 |
| 30 | `192.168.30.0/24` | `192.168.30.2` | `192.168.30.3` | `192.168.30.1` | DSW1 |
| 40 | `192.168.40.0/24` | `192.168.40.2` | `192.168.40.3` | `192.168.40.1` | DSW2 |

The SVI address of each distribution switch is a real address. Hosts should use the HSRP virtual IP as their default gateway.

## Access switch host ports

- Gi0/3–Gi0/4: VLAN 10
- Gi0/5–Gi0/6: VLAN 20
- Gi0/7–Gi0/8: VLAN 30
- Gi0/9–Gi0/10: VLAN 40
- Gi0/1 and Gi0/2: trunks to DSW1/DSW2 respectively

If your EVE-NG image uses different interface names, change every affected interface reference consistently.
