# Lab Guide — IPv6 Multi-Area OSPFv3

## 1. Objective
Build and verify an IPv6 routed network using OSPFv3 with Area 0 and Area 1. R3 acts as the Area Border Router (ABR) because it has one OSPF interface in each area.

## 2. Topology roles
- R1 and R2: internal Area 0 routers.
- R3: Area 0 / Area 1 ABR.
- R6: internal Area 1 router.
- VPC4 and VPC5: IPv6 end hosts on Area 0 LANs.

## 3. OSPF design
- OSPFv3 process ID: 10 (locally significant; it does not need to match on every router).
- Router IDs: R1 1.1.1.1, R2 2.2.2.2, R3 3.3.3.3, R6 6.6.6.6.
- Area 0: R1–R2, R2–R3, and both user LANs.
- Area 1: R3–R6.
- IPv6 routing must be enabled globally on every router with `ipv6 unicast-routing`.

## 4. VPCS host addressing
At VPC4:
```text
ip 2001:DB8:1:10::10/64 2001:DB8:1:10::1
save
show
```
At VPC5:
```text
ip 2001:DB8:3:30::30/64 2001:DB8:3:30::1
save
show
```
VPCS command syntax can vary by version. If your VPCS build rejects the command, check its built-in `?` help and use the IPv6 address command supported by that version.

## 5. Configuration sequence
1. Confirm the EVE-NG interface connections match the topology image.
2. Configure IPv6 addresses and `no shutdown` on R1, R2, R3, and R6.
3. Enable IPv6 forwarding on each router: `ipv6 unicast-routing`.
4. Create OSPFv3 process 10 and configure a unique router ID on each router.
5. Enable OSPFv3 on each routed interface with `ipv6 ospf 10 area <area-id>`.
6. Configure VPC4 and VPC5 IPv6 addresses and default gateways.
7. Wait for OSPFv3 adjacencies to form, then verify routes and end-to-end reachability.

## 6. Verification commands
Run on each router as appropriate:
```text
show ipv6 interface brief
show ipv6 ospf
show ipv6 ospf neighbor
show ipv6 ospf interface brief
show ipv6 route
show ipv6 route ospf
show running-config
```
Expected results:
- R1–R2, R2–R3, and R3–R6 form OSPFv3 neighbor relationships.
- R3 participates in both Area 0 and Area 1 and functions as the ABR.
- R6 learns Area 0 routes as inter-area OSPF routes.
- R1/R2 learn the Area 1 link prefix `2001:DB8:3:40::/64` as an inter-area route.
- VPC4 can ping VPC5, and vice versa, after host addressing and routing are correct.

## 7. Connectivity tests
From VPC4:
```text
ping 2001:DB8:1:10::1
ping 2001:DB8:3:30::30
```
From VPC5:
```text
ping 2001:DB8:3:30::1
ping 2001:DB8:1:10::10
```
From R6, test reachability to the remote LAN gateway:
```text
ping 2001:DB8:1:10::1
ping 2001:DB8:3:30::1
```

## 8. Wireshark verification
Capture on the relevant EVE-NG link or virtual network interface. Useful display filters:
```text
ospf
icmpv6
ipv6
```
Inspect OSPFv3 Hello packets and neighbor formation. Use ICMPv6 Echo Request/Reply packets to confirm host-to-host reachability. Depending on the capture point and Wireshark version, OSPFv3 may be decoded under the OSPF protocol display filter.

## 9. Troubleshooting checklist
- Check interface names and cabling against the topology.
- Check each interface is up/up and has the intended IPv6 prefix.
- Confirm `ipv6 unicast-routing` is present on every router.
- Confirm each router has a unique OSPF router ID.
- Confirm OSPF area assignments match on both ends of every router link.
- Check `show ipv6 ospf neighbor` for missing adjacencies.
- Check `show ipv6 route ospf` for learned routes.
- Confirm VPC default gateways point to the router's LAN IPv6 address.
- Check for duplicate IPv6 addresses or incorrect prefix lengths.

## 10. Completion criteria
The lab is complete when all expected OSPFv3 adjacencies are established, R3 operates as the Area Border Router, inter-area routes are present, and VPC4 and VPC5 can exchange ICMPv6 traffic.

## Important platform note
The supplied configurations use Cisco IOS-style OSPFv3 interface commands. Exact command availability can differ by router image and software release. If a command is rejected, check the image's supported IPv6 OSPF syntax before proceeding.
