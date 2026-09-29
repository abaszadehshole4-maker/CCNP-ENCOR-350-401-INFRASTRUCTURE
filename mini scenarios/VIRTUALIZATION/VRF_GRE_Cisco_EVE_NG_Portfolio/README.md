# VRF + GRE Inter-LAN Connectivity Lab

**Creator:** Sholeh Abaszadeh  
**Platform:** EVE-NG  
**Technology:** Cisco IOS / IOSv  
**Level:** CCNP Enterprise / Portfolio Lab

---

## 1. Project Overview

This lab demonstrates how to provide connectivity between two customer LANs when the customer routing domain is isolated in a **VRF (Virtual Routing and Forwarding)** and the two customer sites are connected through a **GRE tunnel** across an IP underlay.

The lab is intentionally built in stages so that each layer can be verified independently:

1. Physical/interface connectivity
2. IP underlay reachability
3. VRF creation
4. Customer LAN interfaces placed into the VRF
5. GRE tunnel creation
6. GRE tunnel placed into the VRF
7. Static routing inside the VRF
8. End-to-end LAN-to-LAN connectivity
9. Verification and troubleshooting

The final result is:

```text
PC1 ── LAN-A ── R1 ═════ GRE ═════ R2 ── LAN-B ── PC2
                 \                 /
                  CUSTOMER VRF
```

---

## 2. Lab Objectives

After completing this lab, you should be able to:

- Explain the difference between the **global routing table** and a **VRF routing table**.
- Configure VRF-Lite on Cisco IOS.
- Place an interface into a VRF.
- Configure a GRE tunnel between two routers.
- Understand the relationship between the GRE **underlay** and **overlay**.
- Place a GRE tunnel interface into a VRF.
- Configure static routes inside a VRF.
- Verify traffic using VRF-aware commands.
- Troubleshoot underlay, VRF, GRE, and routing problems systematically.
- Explain packet flow from one customer LAN to another.

---

## 3. Topology

```text
                         GLOBAL IP UNDERLAY
                         10.0.12.0/30

                Gi0/1                 Gi0/1
        +----------------+     +----------------+
        |       R1       |=====|       R2       |
        | 10.0.12.1/30  |     | 10.0.12.2/30  |
        +-------+--------+     +--------+-------+
                |                         |
                |       GRE Tunnel        |
                |   Tunnel0 172.16.12.0/30
                +=========================+
                 CUSTOMER VRF OVERLAY

             CUSTOMER VRF                 CUSTOMER VRF
          192.168.10.0/24              192.168.20.0/24
                 |                         |
              Gi0/0                     Gi0/0
                 |                         |
          +------+-----+             +-----+------+
          |    PC1     |             |    PC2     |
          | .10.10     |             | .20.10     |
          +------------+             +------------+

PC1: 192.168.10.10/24
GW : 192.168.10.1

PC2: 192.168.20.10/24
GW : 192.168.20.1
```

### Logical separation

**Underlay / global routing:**

```text
R1 Gi0/1 10.0.12.1
       |
       | IP
       |
R2 Gi0/1 10.0.12.2
```

**Overlay / CUSTOMER VRF:**

```text
192.168.10.0/24
       |
      R1
       |
  GRE Tunnel
       |
      R2
       |
192.168.20.0/24
```

---

## 4. Addressing Plan

| Device | Interface | VRF | Address | Purpose |
|---|---|---|---|---|
| R1 | Gi0/0 | CUSTOMER | 192.168.10.1/24 | LAN-A gateway |
| R1 | Gi0/1 | Global | 10.0.12.1/30 | GRE underlay |
| R1 | Tunnel0 | CUSTOMER | 172.16.12.1/30 | GRE overlay |
| R2 | Gi0/0 | CUSTOMER | 192.168.20.1/24 | LAN-B gateway |
| R2 | Gi0/1 | Global | 10.0.12.2/30 | GRE underlay |
| R2 | Tunnel0 | CUSTOMER | 172.16.12.2/30 | GRE overlay |
| PC1 | NIC | — | 192.168.10.10/24 | Host |
| PC2 | NIC | — | 192.168.20.10/24 | Host |

VRF:

```text
Name: CUSTOMER
RD:   65000:100
```

---

## 5. Packet Flow

When PC1 sends traffic to PC2:

```text
PC1
192.168.10.10
      |
      v
R1 Gi0/0
      |
      | CUSTOMER VRF
      v
R1 routing table for CUSTOMER
      |
      | route 192.168.20.0/24
      v
Tunnel0
172.16.12.1
      |
      | GRE encapsulation
      v
Underlay
10.0.12.1 ---> 10.0.12.2
      |
      v
R2 Tunnel0
172.16.12.2
      |
      | CUSTOMER VRF
      v
R2 Gi0/0
      |
      v
PC2
192.168.20.10
```

The **outer IP packet** uses the underlay:

```text
10.0.12.1 -> 10.0.12.2
```

The **inner/customer packet** is:

```text
192.168.10.10 -> 192.168.20.10
```

---

# 6. Step-by-Step Configuration

## Step 1 — Configure PC1

VPCS:

```text
ip 192.168.10.10/24 192.168.10.1
save
```

Verify:

```text
show ip
```

---

## Step 2 — Configure PC2

VPCS:

```text
ip 192.168.20.10/24 192.168.20.1
save
```

Verify:

```text
show ip
```

---

# 7. R1 Configuration

## 7.1 Hostname

```cisco
enable
configure terminal
hostname R1
```

## 7.2 Create the VRF

```cisco
vrf definition CUSTOMER
 rd 65000:100
exit
```

Verify:

```cisco
show vrf
```

---

## 7.3 Configure the LAN interface

```cisco
interface GigabitEthernet0/0
 vrf forwarding CUSTOMER
 ip address 192.168.10.1 255.255.255.0
 no shutdown
exit
```

Important: `vrf forwarding CUSTOMER` normally removes the old IP address from the interface, so the IP address must be configured again afterward.

---

## 7.4 Configure the underlay interface

```cisco
interface GigabitEthernet0/1
 ip address 10.0.12.1 255.255.255.252
 no shutdown
exit
```

Verify:

```cisco
show ip interface brief
```

---

## 7.5 Configure GRE

```cisco
interface Tunnel0
 vrf forwarding CUSTOMER
 ip address 172.16.12.1 255.255.255.252
 tunnel source GigabitEthernet0/1
 tunnel destination 10.0.12.2
 tunnel mode gre ip
 no shutdown
exit
```

---

## 7.6 Configure the remote LAN route

```cisco
ip route vrf CUSTOMER 192.168.20.0 255.255.255.0 172.16.12.2
```

---

## 7.7 Save

```cisco
end
write memory
```

---

# 8. R2 Configuration

## 8.1 Hostname

```cisco
enable
configure terminal
hostname R2
```

## 8.2 Create the VRF

```cisco
vrf definition CUSTOMER
 rd 65000:100
exit
```

## 8.3 Configure the LAN interface

```cisco
interface GigabitEthernet0/0
 vrf forwarding CUSTOMER
 ip address 192.168.20.1 255.255.255.0
 no shutdown
exit
```

## 8.4 Configure the underlay

```cisco
interface GigabitEthernet0/1
 ip address 10.0.12.2 255.255.255.252
 no shutdown
exit
```

## 8.5 Configure GRE

```cisco
interface Tunnel0
 vrf forwarding CUSTOMER
 ip address 172.16.12.2 255.255.255.252
 tunnel source GigabitEthernet0/1
 tunnel destination 10.0.12.1
 tunnel mode gre ip
 no shutdown
exit
```

## 8.6 Configure the remote LAN route

```cisco
ip route vrf CUSTOMER 192.168.10.0 255.255.255.0 172.16.12.1
```

## 8.7 Save

```cisco
end
write memory
```

---

# 9. Verification — Perform These Tests in Order

## Test 1 — Physical interfaces

R1:

```cisco
show ip interface brief
```

R2:

```cisco
show ip interface brief
```

Expected:

```text
Gi0/0    up    up
Gi0/1    up    up
```

---

## Test 2 — Underlay connectivity

R1:

```cisco
ping 10.0.12.2
```

R2:

```cisco
ping 10.0.12.1
```

Expected:

```text
!!!!!
```

Do not troubleshoot GRE until the underlay works.

---

## Test 3 — Verify VRF

```cisco
show vrf
```

Expected:

```text
CUSTOMER    65000:100
```

---

## Test 4 — Verify the VRF LAN route

R1:

```cisco
show ip route vrf CUSTOMER
```

Expected connected route:

```text
C    192.168.10.0/24
```

R2:

```cisco
show ip route vrf CUSTOMER
```

Expected:

```text
C    192.168.20.0/24
```

---

## Test 5 — Verify GRE

```cisco
show interface Tunnel0
```

Expected:

```text
Tunnel0 is up, line protocol is up
```

Also:

```cisco
show run interface Tunnel0
```

---

## Test 6 — Test the tunnel IP

R1:

```cisco
ping vrf CUSTOMER 172.16.12.2
```

R2:

```cisco
ping vrf CUSTOMER 172.16.12.1
```

Expected:

```text
!!!!!
```

---

## Test 7 — Verify remote routes

R1:

```cisco
show ip route vrf CUSTOMER 192.168.20.0
```

Expected:

```text
S    192.168.20.0/24
     via 172.16.12.2
```

R2:

```cisco
show ip route vrf CUSTOMER 192.168.10.0
```

Expected:

```text
S    192.168.10.0/24
     via 172.16.12.1
```

---

## Test 8 — Router-to-router LAN test

R1:

```cisco
ping vrf CUSTOMER 192.168.20.1
```

R2:

```cisco
ping vrf CUSTOMER 192.168.10.1
```

Expected:

```text
!!!!!
```

---

## Test 9 — End-to-end test

From PC1:

```text
ping 192.168.20.10
```

Expected:

```text
64 bytes from 192.168.20.10
```

From PC2:

```text
ping 192.168.10.10
```

Expected:

```text
64 bytes from 192.168.10.10
```

---

# 10. Troubleshooting Methodology

Use the following troubleshooting hierarchy:

```text
Layer 1
  |
  v
Interfaces
  |
  v
Underlay
  |
  v
VRF
  |
  v
GRE
  |
  v
VRF routes
  |
  v
End-to-end connectivity
```

---

## Problem A — Underlay ping fails

Check:

```cisco
show ip interface brief
show run interface GigabitEthernet0/1
ping 10.0.12.2
```

Check:

- Interface status
- IP address
- /30 mask
- Cable/link in EVE-NG
- Correct interface mapping

---

## Problem B — Tunnel is down

Check:

```cisco
show interface Tunnel0
show run interface Tunnel0
```

Then verify:

```cisco
ping 10.0.12.2
```

Check both routers have matching:

```text
tunnel source
tunnel destination
```

R1:

```text
source      10.0.12.1
destination 10.0.12.2
```

R2:

```text
source      10.0.12.2
destination 10.0.12.1
```

---

## Problem C — Tunnel is up but VRF ping fails

Run:

```cisco
show ip route vrf CUSTOMER
```

Then:

```cisco
ping vrf CUSTOMER 172.16.12.2
```

Check that Tunnel0 is actually in CUSTOMER:

```cisco
show vrf
show ip interface Tunnel0
```

---

## Problem D — Remote LAN route is missing

R1:

```cisco
show ip route vrf CUSTOMER
```

You need:

```text
192.168.20.0/24
```

R2 needs:

```text
192.168.10.0/24
```

Check static routes:

```cisco
show run | include ip route
```

---

## Problem E — Router can reach remote LAN gateway but PC cannot

Check PC configuration:

```text
PC1:
192.168.10.10/24
gateway 192.168.10.1

PC2:
192.168.20.10/24
gateway 192.168.20.1
```

On routers:

```cisco
show ip arp vrf CUSTOMER
```

Check that each router has ARP for its local host.

---

# 11. Useful Advanced Verification Commands

```cisco
show vrf
show ip route
show ip route vrf CUSTOMER
show ip route vrf CUSTOMER 192.168.20.0
show ip interface brief
show ip interface GigabitEthernet0/0
show ip interface Tunnel0
show interfaces Tunnel0
show run interface Tunnel0
show run interface GigabitEthernet0/0
show run interface GigabitEthernet0/1
show ip arp vrf CUSTOMER
```

VRF-aware ping:

```cisco
ping vrf CUSTOMER 192.168.20.10
```

VRF-aware traceroute:

```cisco
traceroute vrf CUSTOMER 192.168.20.10
```

---

# 12. Useful Debug Commands

Use debugging carefully in a lab.

```cisco
debug tunnel
```

After testing:

```cisco
undebug all
```

You can also check interface counters:

```cisco
show interfaces Tunnel0
```

Look for:

```text
packets input
packets output
drops
errors
```

---

# 13. Common Mistakes

### Mistake 1 — Using the global routing table

Incorrect troubleshooting:

```cisco
ping 192.168.20.10
```

Better:

```cisco
ping vrf CUSTOMER 192.168.20.10
```

---

### Mistake 2 — Forgetting the VRF on the LAN interface

Check:

```cisco
show ip interface GigabitEthernet0/0
```

---

### Mistake 3 — Forgetting the remote LAN route

R1 needs:

```cisco
ip route vrf CUSTOMER 192.168.20.0 255.255.255.0 172.16.12.2
```

R2 needs:

```cisco
ip route vrf CUSTOMER 192.168.10.0 255.255.255.0 172.16.12.1
```

---

### Mistake 4 — Underlay is broken

GRE cannot function correctly if the tunnel endpoints cannot reach one another through the underlay.

---

### Mistake 5 — Wrong tunnel destination

R1 must point to R2's underlay address and vice versa.

---

# 14. Key Concepts

## VRF

VRF creates a separate routing table.

Instead of only:

```text
show ip route
```

we can have:

```text
show ip route vrf CUSTOMER
```

The CUSTOMER routing table is isolated from the global routing table.

---

## GRE

GRE creates a logical tunnel across an IP network.

```text
R1 ================= R2
       GRE Tunnel
```

GRE itself does not provide encryption.

---

## Underlay

The physical IP network:

```text
10.0.12.0/30
```

is the underlay.

---

## Overlay

The GRE tunnel:

```text
172.16.12.0/30
```

is the overlay.

---

# 15. Portfolio Challenge

After completing the base lab, modify it yourself.

### Challenge 1 — Replace static routing with OSPF

Run OSPF inside the CUSTOMER VRF over the GRE tunnel.

Goal:

```text
R1 <--- OSPF ---> R2
```

---

### Challenge 2 — Add a second LAN

Add:

```text
192.168.30.0/24
```

behind R1.

Make it reachable from PC2.

---

### Challenge 3 — Add IPv6

Add IPv6 addressing to:

- LAN-A
- LAN-B
- GRE tunnel

Then provide IPv6 connectivity between the LANs.

---

### Challenge 4 — Route filtering

Use prefix-lists and route-maps so that only selected customer prefixes are advertised.

---

### Challenge 5 — Troubleshooting

Intentionally introduce:

- Wrong tunnel destination
- Missing VRF
- Wrong static route
- Wrong subnet mask
- Missing default gateway
- Wrong tunnel source

Then document the symptoms, commands, and fix.

---

# 16. Suggested GitHub Repository Structure

```text
VRF-GRE-Cisco-EVE-NG/
│
├── README.md
│
├── eve-ng/
│   ├── topology.unl
│   └── topology.txt
│
├── configs/
│   ├── R1.cfg
│   ├── R2.cfg
│   ├── PC1.txt
│   └── PC2.txt
│
└── docs/
    ├── verification.md
    └── troubleshooting.md
```

---

# 17. Portfolio Description

This project demonstrates a Cisco VRF-Lite and GRE overlay implementation using EVE-NG. Two customer LANs are isolated inside a dedicated VRF and interconnected through a GRE tunnel over an IP underlay. The lab includes complete device configurations, staged verification, VRF-aware routing commands, GRE troubleshooting, and an extension path toward OSPF, IPv6, and route filtering.

---

## Author

**Sholeh Abaszadeh**

Cisco Networking / CCNP Enterprise Lab Portfolio

