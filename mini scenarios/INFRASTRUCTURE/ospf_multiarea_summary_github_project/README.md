# Multi-Area OSPF and Inter-Area Route Summarization (EVE-NG)

A six-router Cisco IOS lab based on the supplied topology. It demonstrates a single OSPF process per router, three OSPF areas (Area 0, Area 1, Area 2), and inter-area route summarization on the two Area Border Routers (ABRs).

## Five project folders

- `configs/` — configuration files for P1R1, P1R2, P1R3, P2R1, P2R2, and P2R3
- `docs/` — addressing, design decisions, step-by-step configuration, verification, and troubleshooting
- `diagrams/` — clean topology image in PNG/SVG and the supplied topology reference image
- `wireshark/` — capture/display filters and expected OSPF packet observations
- `evidence/` — a place for your own screenshots and packet captures

## Important interpretation of the supplied diagram

The diagram labels some regions `Process ID 1`, `Process ID 2`, and `Process ID 3`. An OSPF **process ID is locally significant on a router; it is not an area number**. To implement the requested *multi-area OSPF with OSPF area summarization*, this project uses OSPF process `1` on each router and areas `0`, `1`, and `2` as drawn. If the actual assignment requires separate OSPF processes 1/2/3 on the same router(s), that is a different multi-process OSPF/redistribution lab; `area range` does not summarize routes between independent OSPF processes.

## Addressing summary

| Router | Interface | Address | OSPF area |
|---|---|---:|---:|
| P1R1 | Fa0/0 | 10.100.100.1/24 | 0 |
| P2R1 | Fa0/0 | 10.100.100.2/24 | 0 |
| P1R1 | S0/0 | 192.168.1.33/28 | 1 |
| P1R2 | S0/0 | 192.168.1.34/28 | 1 |
| P1R2 | Fa0/0 | 192.168.1.49/28 | 1 |
| P1R3 | Fa0/0 | 192.168.1.50/28 | 1 |
| P2R1 | S0/0 | 192.168.2.33/28 | 2 |
| P2R2 | S0/0 | 192.168.2.34/28 | 2 |
| P2R2 | Fa0/0 | 192.168.2.49/28 | 2 |
| P2R3 | Fa0/0 | 192.168.2.50/28 | 2 |
| P1R1 | Loopback0 | 192.168.1.1/28 | 1 |
| P1R2 | Loopback0 | 192.168.1.17/28 | 1 |
| P2R1 | Loopback0 | 192.168.2.1/28 | 2 |
| P2R2 | Loopback0 | 192.168.2.17/28 | 2 |

## Summaries

- P1R1 summarizes Area 1 routes into the backbone as `192.168.1.0/26`.
- P2R1 summarizes Area 2 routes into the backbone as `192.168.2.0/26`.

Each `/26` covers four `/28` blocks (`.0/28`, `.16/28`, `.32/28`, `.48/28`). These address allocations are aligned for summarization.

## Quick start

1. Import six compatible IOS routers into EVE-NG and connect them according to `diagrams/topology.png`.
2. Ensure interface names on your image match `FastEthernet0/0` and `Serial0/0`; adapt names if needed.
3. Apply each matching config in `configs/` or use it as a command checklist.
4. On the DCE end of each serial link, configure a clock rate if required by your simulator/device (for example, `clock rate 64000`). Do not configure a clock rate on the DTE end.
5. Verify adjacency and routes using the commands in `docs/verification-and-troubleshooting.md`.
6. Capture OSPF packets using `wireshark/capture-guide.md` and put your genuine artifacts in `evidence/`.

## Safety and lab assumptions

- This is a lab template, not tested against your exact IOS image or physical interfaces.
- Loopbacks retain the `/28` masks shown in the supplied diagram. The configs use `ip ospf network point-to-point` under each Loopback0 so IOS advertises the configured loopback prefix rather than the default OSPF loopback `/32` host route. If unsupported on your IOS version, adjust to your platform's supported method or intentionally use `/32` loopbacks.
- Serial interface clocking depends on which end is DCE.
- `.cfg` files use traditional IOS interface naming; use `show ip interface brief` and adapt on IOS XE models with different names.
- No Wireshark captures are fabricated or included. Add your own captures/screenshots after practicing.
