# Addressing Plan

## VRF 10 - USERS

| Interface / node | IP | Mask | Purpose |
|---|---:|---:|---|
| FGT port2 | 203.0.113.2 | /30 | VRF 10 WAN |
| R-ISP Gi0/0 | 203.0.113.1 | /30 | Upstream next hop |
| FGT VLAN10-USERS | 10.10.10.1 | /24 | USERS gateway |
| PC-USERS | 10.10.10.10 | /24 | End host |
| R-ISP Loopback0 | 8.8.8.8 | /32 | Test endpoint |

Default route in VRF 10: `0.0.0.0/0 via 203.0.113.1, port2`.

Blackhole route in VRF 10: `10.20.20.0/24`.

## VRF 20 - APPS

| Interface / node | IP | Mask | Purpose |
|---|---:|---:|---|
| FGT port4 | 198.51.100.2 | /30 | VRF 20 WAN |
| R-ISP Gi0/1 | 198.51.100.1 | /30 | Upstream next hop |
| FGT VLAN20-APPS | 10.20.20.1 | /24 | APPS gateway |
| PC-APPS | 10.20.20.10 | /24 | End host |
| R-ISP Loopback1 | 1.1.1.1 | /32 | Test endpoint |

Default route in VRF 20: `0.0.0.0/0 via 198.51.100.1, port4`.

Blackhole route in VRF 20: `10.10.10.0/24`.

## Why two default routes?

The same FortiGate has two distinct routing tables. The USERS interfaces use VRF 10 and can use only the VRF 10 default route through port2. The APPS interfaces use VRF 20 and can use only the VRF 20 default route through port4. The Cisco router is shared as an upstream test device, but the two FortiGate WAN links remain separate Layer-3 paths.
