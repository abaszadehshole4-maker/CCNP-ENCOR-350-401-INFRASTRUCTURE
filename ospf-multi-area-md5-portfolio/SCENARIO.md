# Scenario: Multi-Area OSPF with Interface Activation and MD5 Authentication

## Business context

A small enterprise is migrating from a flat OSPF design to a structured multi-area topology. RouterA and RouterB form the Area 0 backbone. RouterC serves a remote segment in Area 130, while RouterD serves another remote segment in Area 140.

The goal is to build the routing domain using interface-level OSPF configuration and to protect the backbone adjacency with classic MD5 authentication.

## Requirements

1. Configure OSPF process ID **10** on RouterA, RouterB, RouterC, and RouterD.
2. Do **not** use the OSPF `network` command. Activate OSPF directly on participating interfaces.
3. Use each router's Loopback0 IPv4 /32 address as its manually configured OSPF router ID.
4. Place the RouterA–RouterB link and both Loopback0 interfaces of RouterA and RouterB in **Area 0**.
5. Place the RouterA–RouterC link and RouterC Loopback0 in **Area 130**.
6. Place the RouterB–RouterD link and RouterD Loopback0 in **Area 140**.
7. Configure classic OSPF message-digest authentication on the RouterA–RouterB interfaces using key ID **7** and password **LabAuth-2026**.
8. Verify all expected OSPF adjacencies and confirm that remote Loopback networks are reachable.

## Expected result

The final domain should contain three OSPF areas with a working Area 0 backbone. RouterA and RouterB should operate as ABRs. The Area 0 neighbor relationship should reach FULL state and remain operational with MD5 authentication enabled.
