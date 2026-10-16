# Addressing and design

## Logical topology

- P1R1 and P2R1 are Area Border Routers (ABRs). Each connects Area 0 to one non-backbone area.
- P1R1/P1R2/P1R3 participate in Area 1 for the left-side subnetworks.
- P2R1/P2R2/P2R3 participate in Area 2 for the right-side subnetworks.
- The shared `10.100.100.0/24` Ethernet segment is Area 0.
- Run OSPF process 1 on each router. Process IDs need not match between routers, but using 1 everywhere makes the lab easier to follow.

## Router-by-router interface and area table

| Router | Interface | Address/mask | Area | Neighbor/link |
|---|---|---|---:|---|
| P1R1 | Fa0/0 | 10.100.100.1/24 | 0 | P2R1 on backbone LAN |
| P1R1 | S0/0 | 192.168.1.33/28 | 1 | P1R2 S0/0 `.34` |
| P1R1 | Lo0 | 192.168.1.1/28 | 1 | Loopback prefix |
| P1R2 | S0/0 | 192.168.1.34/28 | 1 | P1R1 S0/0 `.33` |
| P1R2 | Fa0/0 | 192.168.1.49/28 | 1 | P1R3 Fa0/0 `.50` via switch |
| P1R2 | Lo0 | 192.168.1.17/28 | 1 | Loopback prefix |
| P1R3 | Fa0/0 | 192.168.1.50/28 | 1 | P1R2 Fa0/0 `.49` via switch |
| P2R1 | Fa0/0 | 10.100.100.2/24 | 0 | P1R1 on backbone LAN |
| P2R1 | S0/0 | 192.168.2.33/28 | 2 | P2R2 S0/0 `.34` |
| P2R1 | Lo0 | 192.168.2.1/28 | 2 | Loopback prefix |
| P2R2 | S0/0 | 192.168.2.34/28 | 2 | P2R1 S0/0 `.33` |
| P2R2 | Fa0/0 | 192.168.2.49/28 | 2 | P2R3 Fa0/0 `.50` via switch |
| P2R2 | Lo0 | 192.168.2.17/28 | 2 | Loopback prefix |
| P2R3 | Fa0/0 | 192.168.2.50/28 | 2 | P2R2 Fa0/0 `.49` via switch |

## Why summarize to /26?

The left-side subnets fit inside `192.168.1.0/26`:
- `192.168.1.0/28` — P1R1 Loopback0
- `192.168.1.16/28` — P1R2 Loopback0
- `192.168.1.32/28` — P1R1–P1R2 serial link
- `192.168.1.48/28` — P1R2–P1R3 LAN

The right side mirrors it under `192.168.2.0/26`.

`area 1 range 192.168.1.0 255.255.255.192` goes under the OSPF process on the ABR P1R1. It summarizes routes from Area 1 when advertising into other areas. `area 2 range 192.168.2.0 255.255.255.192` does the same on P2R1 for Area 2.
