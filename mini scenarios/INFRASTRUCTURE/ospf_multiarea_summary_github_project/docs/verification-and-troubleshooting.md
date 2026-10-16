# Verification and troubleshooting

Run these on each router as appropriate:

```text
show ip interface brief
show ip ospf interface brief
show ip ospf neighbor
show ip protocols
show ip route ospf
show ip route 192.168.1.0
show ip route 192.168.2.0
show ip ospf database summary
show running-config | section router ospf
```

On P1R1 and P2R1, inspect the configured summary ranges:

```text
show running-config | section router ospf
show ip ospf database summary
```

Expected behavior:
- P1R1 and P2R1 form an OSPF neighbor relationship across Area 0.
- P1R1 and P1R2 form a neighbor relationship across the left serial link (Area 1).
- P1R2 and P1R3 form a neighbor relationship across the left LAN (Area 1).
- P2R1 and P2R2 form a neighbor relationship across the right serial link (Area 2).
- P2R2 and P2R3 form a neighbor relationship across the right LAN (Area 2).
- Routers in the opposite non-backbone area learn summary routes: `O IA 192.168.1.0/26` or `O IA 192.168.2.0/26`.

Troubleshooting order:

1. Check physical / virtual cabling and `up/up` status.
2. Verify each end of a link has addresses in the same subnet and correct masks.
3. For serial links, check DCE clock rate if required and confirm encapsulations match.
4. Ensure OSPF area IDs match on both ends of each link.
5. Check hello/dead timers, authentication, MTU, and network type if neighbors do not reach FULL.
6. Confirm Area 0 adjacency before troubleshooting summary propagation.
7. Confirm the `area X range` command is applied on the ABR under the correct OSPF process and that the component prefixes are actually in that area.
8. Remember Loopback0 is configured with `ip ospf network point-to-point` to advertise its configured `/28` mask in supported IOS. Without that command, OSPF usually advertises loopbacks as `/32` host routes.

IOS interface naming may vary by image. Adapt commands to the interface names reported by `show ip interface brief`.
