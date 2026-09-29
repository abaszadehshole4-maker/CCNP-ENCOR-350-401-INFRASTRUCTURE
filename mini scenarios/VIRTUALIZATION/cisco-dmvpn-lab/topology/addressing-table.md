# Addressing Table

| Device | Interface | IPv4 Address | Mask | Role |
|---|---|---:|---:|---|
| R1 | G0/0 | 172.16.0.1 | /24 | DMVPN Hub underlay |
| R2 | G0/0 | 172.16.0.2 | /24 | Spoke underlay |
| R3 | G0/0 | 172.16.0.3 | /24 | Spoke underlay |
| R1 | Tunnel0 | 10.255.0.1 | /24 | DMVPN overlay |
| R2 | Tunnel0 | 10.255.0.2 | /24 | DMVPN overlay |
| R3 | Tunnel0 | 10.255.0.3 | /24 | DMVPN overlay |
| R2 | G0/1 | 10.10.10.1 | /24 | Branch LAN gateway |
| R3 | G0/1 | 10.10.20.1 | /24 | Branch LAN gateway |
| PC1 | NIC | 10.10.10.10 | /24 | Branch host |
| PC2 | NIC | 10.10.20.10 | /24 | Branch host |

## Networks

- Underlay: `172.16.0.0/24`
- DMVPN overlay: `10.255.0.0/24`
- R2 LAN: `10.10.10.0/24`
- R3 LAN: `10.10.20.0/24`

## Tunnel Design

- Tunnel mode: mGRE
- NHRP network ID: `100`
- NHS: R1 / `10.255.0.1`
- Routing protocol: EIGRP AS `100`
