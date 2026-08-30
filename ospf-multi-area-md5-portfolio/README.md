# OSPF Multi-Area + Classic MD5 Authentication Lab

**Creator:** Shole Abaszadeh  
**Project type:** Cisco OSPFv2 portfolio laboratory  
**Platform:** EVE-NG / Cisco IOL L3  

## Overview

This is an independently written networking laboratory for practicing multi-area OSPF, interface-level OSPF activation, ABR behavior, and classic MD5 authentication on an OSPF adjacency.

The lab uses a new addressing plan, different process/area values, different credentials, and original scenario wording. It is intended as a portfolio project rather than as a reproduction of a vendor examination question or answer key.

## Learning objectives

1. Build a four-router OSPFv2 domain with three areas.
2. Configure OSPF directly under interfaces without using the `network` command.
3. Use Loopback0 addresses as manually configured OSPF router IDs.
4. Make RouterA and RouterB ABRs between Area 0 and their respective branch areas.
5. Protect the RouterA–RouterB Area 0 adjacency with classic OSPF MD5 authentication.
6. Verify neighbors, LSDBs, routing tables, area membership, and authentication.
7. Troubleshoot common OSPF problems such as area mismatch, authentication mismatch, and missing interface activation.

## Topology

```text
                         AREA 0
                 10.60.0.0/30
          +---------------------------+
          |                           |
       RouterA                     RouterB
        ABR                           ABR
       Lo0                          Lo0
 10.255.10.1/32                10.255.20.1/32
          |                           |
          | Area 130                  | Area 140
          |                           |
 10.60.130.0/30               10.60.140.0/30
          |                           |
       RouterC                     RouterD
       Area 130                     Area 140
       Lo0                          Lo0
 10.255.30.1/32                10.255.40.1/32
```

## Addressing plan

| Router | Interface | Address | OSPF area | Purpose |
|---|---|---|---:|---|
| RouterA | Loopback0 | 10.255.10.1/32 | 0 | Router ID / management loopback |
| RouterA | Ethernet0/0 | 10.60.0.1/30 | 0 | Core link to RouterB |
| RouterA | Ethernet0/1 | 10.60.130.1/30 | 130 | Branch link to RouterC |
| RouterB | Loopback0 | 10.255.20.1/32 | 0 | Router ID / management loopback |
| RouterB | Ethernet0/0 | 10.60.0.2/30 | 0 | Core link to RouterA |
| RouterB | Ethernet0/1 | 10.60.140.1/30 | 140 | Branch link to RouterD |
| RouterC | Loopback0 | 10.255.30.1/32 | 130 | Router ID / management loopback |
| RouterC | Ethernet0/0 | 10.60.130.2/30 | 130 | Link to RouterA |
| RouterD | Loopback0 | 10.255.40.1/32 | 140 | Router ID / management loopback |
| RouterD | Ethernet0/0 | 10.60.140.2/30 | 140 | Link to RouterB |

## Authentication design

Only the Area 0 adjacency between RouterA and RouterB uses classic OSPF MD5 authentication.

- Authentication type: message-digest (MD5)
- Key ID: `7`
- Lab password: `LabAuth-2026`

The same key ID and password must exist on both sides of the adjacency.

## Step-by-step implementation

### Step 1 — Prepare interfaces

Verify that the interfaces are addressed and operational:

```text
show ip interface brief
```

All required interfaces should be `up/up` before validating OSPF.

### Step 2 — Configure RouterA

```text
conf t
router ospf 10
 router-id 10.255.10.1
exit
interface Ethernet0/0
 ip ospf 10 area 0
 ip ospf authentication message-digest
 ip ospf message-digest-key 7 md5 LabAuth-2026
 no shutdown
exit
interface Ethernet0/1
 ip ospf 10 area 130
 no shutdown
exit
interface Loopback0
 ip ospf 10 area 0
exit
end
```

### Step 3 — Configure RouterB

```text
conf t
router ospf 10
 router-id 10.255.20.1
exit
interface Ethernet0/0
 ip ospf 10 area 0
 ip ospf authentication message-digest
 ip ospf message-digest-key 7 md5 LabAuth-2026
 no shutdown
exit
interface Ethernet0/1
 ip ospf 10 area 140
 no shutdown
exit
interface Loopback0
 ip ospf 10 area 0
exit
end
```

### Step 4 — Configure RouterC

```text
conf t
router ospf 10
 router-id 10.255.30.1
exit
interface Ethernet0/0
 ip ospf 10 area 130
 no shutdown
exit
interface Loopback0
 ip ospf 10 area 130
exit
end
```

### Step 5 — Configure RouterD

```text
conf t
router ospf 10
 router-id 10.255.40.1
exit
interface Ethernet0/0
 ip ospf 10 area 140
 no shutdown
exit
interface Loopback0
 ip ospf 10 area 140
exit
end
```

## Verification workflow

### 1. Check OSPF neighbors

```text
show ip ospf neighbor
```

Expected adjacencies:

- RouterA ↔ RouterB in Area 0
- RouterA ↔ RouterC in Area 130
- RouterB ↔ RouterD in Area 140

### 2. Confirm router IDs

```text
show ip ospf | include Router ID|Routing Process
```

Expected IDs:

- RouterA — `10.255.10.1`
- RouterB — `10.255.20.1`
- RouterC — `10.255.30.1`
- RouterD — `10.255.40.1`

### 3. Confirm interface area membership

```text
show ip ospf interface brief
```

### 4. Confirm MD5 authentication

On RouterA and RouterB:

```text
show ip ospf interface Ethernet0/0
```

Look for message-digest authentication on the core interface.

### 5. Inspect OSPF routes

```text
show ip route ospf
```

Remote loopbacks should be learned through OSPF.

### 6. Test end-to-end reachability

Examples:

```text
RouterC#ping 10.255.40.1
RouterD#ping 10.255.30.1
RouterA#ping 10.255.30.1
RouterB#ping 10.255.40.1
```

## Troubleshooting methodology

Use this order:

1. **Physical/IP layer** — `show ip interface brief`
2. **OSPF process** — `show ip ospf`
3. **OSPF-enabled interfaces** — `show ip ospf interface brief`
4. **Neighbor state** — `show ip ospf neighbor`
5. **Authentication** — `show ip ospf interface Ethernet0/0`
6. **Routing table** — `show ip route ospf`
7. **Detailed interface/packet symptoms** — `show ip ospf interface`

Common faults to introduce for practice:

- Change RouterA's MD5 password so the Area 0 adjacency fails.
- Put RouterC's Ethernet0/0 into Area 0 accidentally.
- Remove `ip ospf 10 area 130` from RouterC's physical interface.
- Configure a duplicate router ID.
- Shut down one side of an inter-router link.

## Portfolio notes

This repository is deliberately written as an original lab exercise. It does not copy the proprietary question text, answer key, explanatory passages, screenshots, or exact addressing from the source material. The technical topic is a general networking concept and the scenario is independently designed for learning and portfolio demonstration.

## Files

```text
ospf-multi-area-md5-portfolio/
├── README.md
├── SCENARIO.md
├── QUICK_START.md
├── LICENSE
├── configs/
│   ├── RouterA.cfg
│   ├── RouterB.cfg
│   ├── RouterC.cfg
│   └── RouterD.cfg
├── eve-ng/
│   └── ospf-multi-area-md5.unl
├── topology/
│   └── ospf-multi-area-md5.drawio
├── verification/
│   └── commands.txt
└── troubleshooting/
    └── commands.txt
```

## EVE-NG image note

The `.unl` references an IOL L3 image name commonly used in EVE-NG labs. If your EVE-NG installation uses a different image filename, edit the node image field or select your local IOL L3 image when opening the lab.

## Save configurations

After successful validation:

```text
copy running-config startup-config
```

## License

The accompanying license file applies to the original files in this repository. Third-party software images are not included and remain subject to their respective licenses.
