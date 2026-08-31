# Enterprise Core Resilience & Operations Lab

**Creator:** NARGES

## Portfolio note

This repository is an independently authored lab exercise built around common Cisco Enterprise Core topics: OSPF, MP-BGP, first-hop redundancy, IP SLA, AAA, NTP, syslog, SNMP, and NetFlow. The topology, IP plan, task wording, verification workflow, and configuration examples in this repository are newly authored and intentionally use different values and organization from the source material that motivated the study project. No source figures, answer scripts, or proprietary text are reproduced.

## Lab goals

By completing this lab, you will practice:

- IPv4 and IPv6 addressing and dual-stack routing
- OSPFv2 and OSPFv3 in a multi-router enterprise core
- Passive interfaces and controlled OSPF adjacency formation
- OSPF path cost and first-hop redundancy with HSRPv2
- IP SLA with object tracking
- eBGP and MP-BGP between an enterprise edge and an upstream ISP
- Default-route propagation from BGP into OSPF
- Route filtering with prefix-lists and route-maps during redistribution
- IPv4/IPv6 management-plane services: AAA/RADIUS, NTP, syslog, SNMP
- Flexible NetFlow / NetFlow Version 9 exporter concepts
- Troubleshooting using show/debug/verification commands

## Platform

Designed for EVE-NG. The `.unl` lab uses generic `vios`, `viosl2`, `vpcs`, and `linux` template names. If your EVE-NG image names differ, change the image/template fields in the `.unl` file or rebuild the topology graphically using the same node names and links.

Suggested nodes:

- 5 routers: ISP, EDGE, CORE, DIST1, DIST2
- 3 switches: ACC1, ACC2, MGMT-SW
- 3 VPCS hosts: PC2, PC3, PC4
- 1 Linux management host: MGMT1

## Topology

```text
                                 ISP
                                  |
                           203.0.113.0/30
                                  |
                               EDGE
                         /                  \
                10.255.0.0/30          10.255.0.4/30
                       /                    \
                     CORE-------------------
                       |\                 / |
                       | \               /  |
                       |  \             /   |
                       |   DIST1-------DIST2
                       |      \         /
                       |       \       /
                       |       ACC1---ACC2
                       |          \\
                       |          MGMT-SW
                       |             |
                       |           MGMT1
                       |
                    Enterprise
                     backbone

DIST1/DIST2 provide HSRP gateways for user VLANs. ACC1/ACC2 are Layer-2 access switches.
MGMT1 provides RADIUS, NTP, syslog and SNMP trap services. NetFlow is exported from EDGE to MGMT1.
```

## VLAN and addressing plan

### Routed links

| Link | Network | Side A | Side B |
|---|---|---|---|
| ISP-EDGE | 203.0.113.0/30 | ISP .1 | EDGE .2 |
| EDGE-CORE | 10.255.0.0/30 | EDGE .1 | CORE .2 |
| CORE-DIST1 | 10.255.0.4/30 | CORE .5 | DIST1 .6 |
| CORE-DIST2 | 10.255.0.8/30 | CORE .9 | DIST2 .10 |
| DIST1-DIST2 | 10.255.0.12/30 | DIST1 .13 | DIST2 .14 |

### Enterprise VLANs

| VLAN | Purpose | Subnet | DIST1 | DIST2 | HSRP VIP |
|---|---|---|---|---|---|
| 110 | Users-A | 10.110.10.0/24 | .1 | .2 | .254 |
| 120 | Users-B | 10.110.20.0/24 | .1 | .2 | .254 |
| 130 | Servers | 10.110.30.0/24 | .1 | .2 | .254 |
| 999 | Native/unused | no hosts | - | - | - |

### Management / host addresses

| Node | Address |
|---|---|
| ISP Lo0 | 198.18.0.1/32 |
| EDGE Lo0 | 10.255.255.1/32 |
| CORE Lo0 | 10.255.255.2/32 |
| DIST1 Lo0 | 10.255.255.3/32 |
| DIST2 Lo0 | 10.255.255.4/32 |
| MGMT1 | 10.110.30.50/24 |
| PC2 | DHCP on VLAN 110 |
| PC3 | DHCP on VLAN 120 |
| PC4 | DHCP on VLAN 130 |

IPv6 enterprise prefix: `2001:db8:110::/48` (lab documentation prefix).

## Build sequence

### Part 1 — Base device configuration

1. Import the `.unl` file into EVE-NG.
2. Start all nodes.
3. Configure hostnames.
4. Configure the IP addresses from the tables above.
5. Enable interfaces with `no shutdown`.
6. Save configurations.

### Part 2 — Layer 2

On ACC1, ACC2 and MGMT-SW:

- Create VLANs 110, 120, 130 and 999.
- Use 802.1Q trunks on switch-to-switch links.
- Make VLAN 999 the native VLAN on trunks.
- Use Rapid PVST+.
- Build one LACP EtherChannel between ACC1 and ACC2.
- Use access ports for PC2/PC3/PC4.
- Configure edge-facing host ports with PortFast and BPDU Guard.

Suggested role assignment:

- DIST1 is primary STP root for VLANs 110 and 130.
- DIST2 is primary STP root for VLAN 120.
- The other distribution switch provides backup root priority.

### Part 3 — Routing

#### OSPFv2

Use process ID 10 and Area 0 on EDGE, CORE, DIST1 and DIST2.

Router IDs:

- EDGE `10.255.255.1`
- CORE `10.255.255.2`
- DIST1 `10.255.255.3`
- DIST2 `10.255.255.4`

Practice:

- Advertise routed links and VLAN interfaces where appropriate.
- Use passive interfaces on user VLANs.
- Keep EDGE's ISP-facing interface out of OSPF.
- Make EDGE the OSPF exit point by propagating a BGP-learned default route.

#### OSPFv3

Use process ID 20 and Area 0 for IPv6. Use the same router-ID values listed above.

#### BGP / MP-BGP

ISP uses AS `64530`.
EDGE uses AS `64540`.

ISP advertises:

- Loopback 0
- IPv4 default route
- IPv6 default route

EDGE learns the defaults and advertises them into OSPFv2/OSPFv3.

### Part 4 — HSRPv2 and IP SLA

Configure HSRPv2 on DIST1 and DIST2 for VLANs 110/120/130.

Desired active gateways:

- VLAN 110: DIST1
- VLAN 120: DIST2
- VLAN 130: DIST1

Use priority 150 on the preferred router and 100 on the backup.

Enable preemption.

Create IP SLA probes to the CORE router. Track the probes and decrement HSRP priority by 60 when the tracked path fails.

Failure test:

1. Confirm the preferred DIST router is Active.
2. Shut the routed uplink toward CORE.
3. Observe the track object transition.
4. Observe HSRP move to the standby distribution switch.
5. Restore the link and verify preemption.

### Part 5 — Management services

MGMT1 provides:

- RADIUS authentication
- NTP service
- Syslog receiver
- SNMPv2c trap receiver
- NetFlow/Flexible NetFlow collector on UDP/9999

Use these lab credentials:

- RADIUS shared secret: `LabRadius!2026`
- Test username: `netadmin`
- Test password: `NetAdmin!2026`
- SNMP community: `NARGES-RO`

These values are unique to this lab and are not intended as production credentials.

### Part 6 — Route filtering challenge

Create an extra static route on EDGE for `192.0.2.0/24` and a second static route for `198.51.100.0/24` toward a Null0 interface or suitable lab next hop.

First redistribute both static routes into OSPF.

Then build this policy:

```text
192.0.2.0/24     -> advertise into OSPF
198.51.100.0/24  -> do not advertise
```

Use:

```text
prefix-list -> route-map -> redistribute static
```

Then verify on CORE/DIST1/DIST2.

## Verification commands

### Interfaces

```cisco
show ip interface brief
show ipv6 interface brief
show interfaces counters errors
```

### OSPF

```cisco
show ip ospf neighbor
show ip ospf interface brief
show ip ospf interface
show ip ospf database
show ip route ospf
show ipv6 ospf neighbor
show ipv6 ospf interface
show ipv6 route ospf
```

### BGP

```cisco
show ip bgp summary
show ip bgp
show ip bgp 0.0.0.0
show bgp ipv6 unicast summary
show bgp ipv6 unicast
```

### HSRP / tracking

```cisco
show standby brief
show standby
show track
show ip sla statistics
```

### Prefix-list / redistribution

```cisco
show ip prefix-list
show route-map
show ip route static
show ip route ospf
```

### Management plane

```cisco
show aaa servers
show running-config | section aaa
show ntp associations
show logging
show snmp
show snmp host
show flow exporter
show flow monitor
```

## Troubleshooting sequence

### OSPF neighbor is not FULL

1. `show ip ospf neighbor`
2. `show ip ospf interface <interface>`
3. Check area ID, hello/dead timers, authentication, network type, MTU and IP subnet.
4. Confirm the interface is not passive.
5. Confirm router IDs are unique.

### Route exists in OSPF DB but not in RIB

1. `show ip ospf database`
2. `show ip route <prefix>`
3. Check administrative distance.
4. Check a `distribute-list` if configured.
5. Check prefix-list/route-map logic for redistributed routes.

### HSRP did not fail over

1. `show standby brief`
2. `show track`
3. `show ip sla statistics`
4. Confirm the tracked object is tied to HSRP.
5. Verify the decrement is large enough to make the standby router preferred.

### OSPF did not learn a default

1. `show ip route 0.0.0.0`
2. `show ip bgp 0.0.0.0`
3. On EDGE, verify `default-information originate`.
4. Verify EDGE actually has the BGP default.
5. Check `show ip ospf database` for the default advertisement.

### Redistribution filter is wrong

1. `show ip prefix-list`
2. `show route-map`
3. Check route-map sequence numbers.
4. Check for an implicit deny at the end of the prefix-list.
5. Verify the redistributed route actually exists in EDGE's routing table.

## Portfolio suggestions

For a GitHub portfolio, add screenshots showing:

- OSPF neighbors in FULL state
- BGP IPv4/IPv6 sessions
- HSRP active/standby before and after failure
- IP SLA/track state change
- OSPF database and routing-table comparison
- Prefix-list and route-map counters
- Syslog and SNMP events on MGMT1
- NetFlow records received by MGMT1

## Suggested repository layout

```text
narges_encyber_core_lab/
├── README.md
├── topology/
│   ├── enterprise_core_lab.unl
│   └── topology.md
├── configs/
│   ├── ISP.cfg
│   ├── EDGE.cfg
│   ├── CORE.cfg
│   ├── DIST1.cfg
│   ├── DIST2.cfg
│   ├── ACC1.cfg
│   ├── ACC2.cfg
│   ├── MGMT-SW.cfg
│   ├── PC2.vpcs
│   ├── PC3.vpcs
│   ├── PC4.vpcs
│   └── MGMT1.setup.sh
└── verification/
    ├── verification.txt
    └── troubleshooting.txt
```
