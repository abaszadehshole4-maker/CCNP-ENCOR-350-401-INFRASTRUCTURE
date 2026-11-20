# IPv6 Multi-Area OSPFv3 — EVE-NG Lab

## Overview
This project demonstrates IPv6 routing with OSPFv3 across two areas. R3 is the Area Border Router (ABR) between Area 0 and Area 1.

## Topology
- R1, R2, and R3 participate in Area 0.
- R3 and R6 share Area 1.
- VPC4 and VPC5 are IPv6 hosts connected to the Area 0 side.
- The original topology image supplied for this lab is in `01_Topology/`.

## Repository structure
```text
IPv6_Multi_Area_OSPFv3_GitHub_Scenario/
├── 01_Topology/
│   └── Original_User_Topology.png
├── 02_Device_Configurations/
│   ├── R1.txt
│   ├── R2.txt
│   ├── R3_ABR.txt
│   └── R6.txt
├── 03_Lab_Guide_and_Verification/
│   ├── IPv6_Addressing_Plan.md
│   ├── Lab_Guide.md
│   └── Lab_Tasks.md
└── 04_GitHub_Documentation/
    ├── README.md
    └── IPv6_Multi_Area_OSPFv3_Lab_Guide.pdf
```

## Addressing note
The R2–R3 link is treated as `2001:DB8:23::/64`, with R2 `::2` and R3 `::3`. The R3–R6 link uses `2001:DB8:3:40::/64`, with R3 `::3` and R6 `::6`. These are proposed endpoint values where the diagram does not clearly show both ends. Review the addressing plan before applying the configurations.

## Quick start
1. Build the topology in EVE-NG and confirm interface cabling.
2. Apply the router configuration files.
3. Configure VPC4 and VPC5 using the host commands in the lab guide.
4. Verify OSPFv3 neighbors, routes, and ICMPv6 connectivity.
5. Capture OSPFv3 and ICMPv6 packets in Wireshark.

## Key verification commands
```text
show ipv6 ospf neighbor
show ipv6 ospf interface brief
show ipv6 route ospf
show ipv6 interface brief
```

See `Lab_Guide.md` for the full procedure, expected results, Wireshark filters, and troubleshooting checklist.

## Technologies
IPv6, OSPFv3, multi-area OSPF, Area Border Router (ABR), EVE-NG, VPCS, Wireshark.
