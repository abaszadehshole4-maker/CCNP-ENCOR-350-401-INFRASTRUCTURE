# Cisco DMVPN Phase 1, Phase 2 & Phase 3 Lab

**Author:** Sholeh Abaszadeh  
**Platform:** Cisco IOS / EVE-NG  
**Focus:** DMVPN, mGRE, NHRP and EIGRP

## 1. Project Overview

This lab demonstrates the evolution of Cisco DMVPN from Phase 1 to Phase 3 using one simple enterprise topology.

The lab is designed as a practical CCNP-level exercise and GitHub portfolio project.

### Technologies

- Dynamic Multipoint VPN (DMVPN)
- mGRE
- NHRP
- EIGRP
- Hub-and-spoke and spoke-to-spoke communication
- NHRP redirect and shortcut
- EVE-NG

> This lab focuses on DMVPN control-plane and routing behavior. IPsec encryption can be added as a separate security extension.

## 2. Enterprise Scenario

A medium-size company has:

- One headquarters (R1)
- Two branch offices (R2 and R3)
- A shared IP underlay network
- A DMVPN overlay network
- A LAN behind each branch

The goal is to understand how DMVPN changes from:

**Phase 1 → Hub-and-spoke**

**Phase 2 → Dynamic spoke-to-spoke**

**Phase 3 → Dynamic spoke-to-spoke with NHRP redirect/shortcut**

## 3. Topology

See:

`topology/topology.png`

Addressing details:

`topology/addressing-table.md`

### Logical topology

```text
                         UNDERLAY
                    172.16.0.0/24
                           |
                 +---------+---------+
                 |                   |
              R2 SPOKE             R3 SPOKE
          172.16.0.2/24        172.16.0.3/24
                 \                   /
                  \                 /
                   \   DMVPN GRE   /
                    \ 10.255.0.0/24
                     \             /
                      +-----------+
                          R1 HUB
                     172.16.0.1/24
```

Branch LANs:

```text
R2 G0/1 --- 10.10.10.0/24 --- PC1
R3 G0/1 --- 10.10.20.0/24 --- PC2
```

## 4. Addressing Plan

| Device | Interface | Address | Purpose |
|---|---|---|---|
| R1 | G0/0 | 172.16.0.1/24 | Underlay |
| R2 | G0/0 | 172.16.0.2/24 | Underlay |
| R3 | G0/0 | 172.16.0.3/24 | Underlay |
| R1 | Tunnel0 | 10.255.0.1/24 | DMVPN overlay |
| R2 | Tunnel0 | 10.255.0.2/24 | DMVPN overlay |
| R3 | Tunnel0 | 10.255.0.3/24 | DMVPN overlay |
| R2 | G0/1 | 10.10.10.1/24 | Branch LAN |
| R3 | G0/1 | 10.10.20.1/24 | Branch LAN |
| PC1 | NIC | 10.10.10.10/24 | Branch host |
| PC2 | NIC | 10.10.20.10/24 | Branch host |

## 5. DMVPN Fundamentals

### mGRE

Multipoint GRE allows one tunnel interface to dynamically communicate with multiple remote peers.

### NHRP

NHRP maps:

**DMVPN tunnel address → physical/NBMA address**

For example:

```text
10.255.0.2 → 172.16.0.2
```

### NHRP NHS

The hub acts as the NHRP Next Hop Server (NHS).

Spokes register their tunnel addresses with the hub.

---

# PHASE 1

## 6. Phase 1 Behavior

Phase 1 is the simplest DMVPN design.

Traffic between spokes travels through the hub:

```text
R2 → R1 → R3
```

There is no dynamic spoke-to-spoke tunnel.

### Important commands

Hub:

```cisco
ip nhrp network-id 100
ip nhrp map multicast dynamic
```

Spoke:

```cisco
ip nhrp network-id 100
ip nhrp nhs 10.255.0.1
ip nhrp map 10.255.0.1 172.16.0.1
ip nhrp map multicast 172.16.0.1
```

## 7. Phase 1 Configuration

Use:

- `config/phase1/R1-HUB.txt`
- `config/phase1/R2-SPOKE.txt`
- `config/phase1/R3-SPOKE.txt`

The hub uses:

```cisco
tunnel mode gre multipoint
```

The spokes also use mGRE, but their NHRP configuration points to the hub.

EIGRP is used to advertise the branch LANs.

On the hub, EIGRP split horizon is disabled on Tunnel0 so routes learned from one spoke can be advertised toward another spoke:

```cisco
no ip split-horizon eigrp 100
```

## 8. Phase 1 Verification

See:

`verification/phase1/verification.md`

Important commands:

```cisco
show dmvpn
show ip nhrp
show ip eigrp neighbors
show ip route eigrp
show ip eigrp topology
ping 10.10.20.10
```

Expected behavior:

- R2 and R3 register with R1.
- The hub has NHRP information for both spokes.
- Spoke-to-spoke traffic uses the hub.
- There is no dynamically created direct spoke-to-spoke NHRP shortcut.

---

# PHASE 2

## 9. Phase 2 Behavior

Phase 2 allows direct spoke-to-spoke communication.

Example:

```text
R2 ---------------- R3
       direct
```

Instead of:

```text
R2 → R1 → R3
```

The routing protocol must preserve the remote spoke as the next hop.

For EIGRP, the hub uses:

```cisco
no ip split-horizon eigrp 100
no ip next-hop-self eigrp 100
```

This allows R2 to learn:

```text
10.10.20.0/24
next-hop = R3
```

rather than:

```text
10.10.20.0/24
next-hop = R1
```

## 10. Phase 2 Configuration

Use:

- `config/phase2/R1-HUB.txt`
- `config/phase2/R2-SPOKE.txt`
- `config/phase2/R3-SPOKE.txt`

The main difference from Phase 1 is the routing behavior.

The hub preserves the EIGRP next-hop information:

```cisco
no ip next-hop-self eigrp 100
```

## 11. Phase 2 Verification

See:

`verification/phase2/verification.md`

Useful commands:

```cisco
show dmvpn
show ip nhrp
show ip route 10.10.20.0
show ip route 10.10.10.0
show ip eigrp topology
ping 10.10.20.10
```

Expected behavior:

- R2 learns the R3 LAN with R3 as the routing next hop.
- R3 learns the R2 LAN with R2 as the routing next hop.
- NHRP resolves the remote spoke's NBMA address.
- Spoke-to-spoke traffic can use a direct GRE path.

---

# PHASE 3

## 12. Phase 3 Behavior

Phase 3 improves scalability.

The hub can initially advertise routes using itself as the next hop. When spoke-to-spoke traffic is detected, NHRP redirect informs the spoke that a better direct path exists.

The spoke then uses NHRP shortcut to create a direct mapping.

Conceptually:

```text
Initial:

R2 → R1 → R3

After NHRP redirect/shortcut:

R2 →→→ R3
```

## 13. Phase 3 Configuration

Hub:

```cisco
ip nhrp redirect
```

Spokes:

```cisco
ip nhrp shortcut
```

Use:

- `config/phase3/R1-HUB.txt`
- `config/phase3/R2-SPOKE.txt`
- `config/phase3/R3-SPOKE.txt`

Phase 3 does not require the Phase 2 EIGRP `no ip next-hop-self` design because NHRP redirect/shortcut provides the optimization mechanism.

## 14. Phase 3 Verification

See:

`verification/phase3/verification.md`

Useful commands:

```cisco
show dmvpn
show ip nhrp
show ip route
ping 10.10.20.10
show ip nhrp detail
```

Look for NHRP shortcut/redirect behavior after generating spoke-to-spoke traffic.

---

# 15. Phase Comparison

| Feature | Phase 1 | Phase 2 | Phase 3 |
|---|---|---|---|
| Hub-and-spoke | Yes | Yes | Yes |
| Direct spoke-to-spoke | No | Yes | Yes |
| NHRP shortcut | No | Dynamic peer resolution | Yes |
| NHRP redirect | No | No | Yes |
| Routing next-hop preservation | Not required | Required | Not required in the same way |
| Scalability | Low | Medium | High |
| Typical learning value | Foundation | Important enterprise design | Advanced/scalable design |

## 16. Troubleshooting Checklist

### Underlay

```cisco
show ip interface brief
ping 172.16.0.1
ping 172.16.0.2
ping 172.16.0.3
```

All routers must have underlay reachability.

### Tunnel

```cisco
show interface tunnel 0
show ip interface tunnel 0
```

Check that Tunnel0 is up/up.

### NHRP

```cisco
show ip nhrp
show ip nhrp detail
```

Check registrations and mappings.

### DMVPN

```cisco
show dmvpn
```

Check tunnel peers and state.

### EIGRP

```cisco
show ip eigrp neighbors
show ip route eigrp
show ip eigrp topology
```

Check adjacency and route learning.

### End-to-end

From PC1:

```text
ping 10.10.20.10
```

From PC2:

```text
ping 10.10.10.10
```

## 17. Common Problems

### Problem 1: Tunnel is down

Check:

```cisco
show ip interface brief
show interface tunnel 0
```

Verify tunnel source and underlay connectivity.

### Problem 2: Spoke does not register

Check:

```cisco
show ip nhrp
```

Verify:

```cisco
ip nhrp nhs 10.255.0.1
ip nhrp map 10.255.0.1 172.16.0.1
ip nhrp map multicast 172.16.0.1
```

### Problem 3: EIGRP neighbor does not form

Check:

```cisco
show ip eigrp neighbors
show ip protocols
```

Verify the Tunnel0 network is included in EIGRP.

### Problem 4: Phase 2 uses the hub

Check the hub Tunnel0:

```cisco
no ip split-horizon eigrp 100
no ip next-hop-self eigrp 100
```

Then inspect:

```cisco
show ip route 10.10.20.0
```

### Problem 5: Phase 3 shortcut does not appear

Generate traffic first:

```cisco
ping 10.10.20.10
```

Then inspect:

```cisco
show ip nhrp
show ip nhrp detail
show dmvpn
```

## 18. Suggested EVE-NG Lab Order

Build and test in this order:

1. Configure the underlay.
2. Verify physical IP connectivity.
3. Build DMVPN Phase 1.
4. Verify NHRP registration.
5. Configure EIGRP.
6. Verify branch route learning.
7. Test Phase 1 traffic.
8. Convert the lab to Phase 2.
9. Verify direct spoke-to-spoke routing.
10. Convert the lab to Phase 3.
11. Configure NHRP redirect/shortcut.
12. Generate traffic.
13. Verify NHRP shortcut behavior.
14. Document screenshots and outputs for GitHub.

## 19. Portfolio Evidence

For a GitHub portfolio, capture screenshots of:

- EVE-NG topology
- `show dmvpn`
- `show ip nhrp`
- `show ip eigrp neighbors`
- `show ip route`
- Phase 1 traffic path
- Phase 2 direct spoke-to-spoke behavior
- Phase 3 NHRP redirect/shortcut behavior

## 20. Security Extension

Classic DMVPN deployments normally combine DMVPN with IPsec to provide encryption over the underlay.

A production-oriented extension can add:

- IKEv1 or IKEv2
- IPsec
- ISAKMP/IPsec profiles
- Authentication
- Encryption
- Integrity
- Key management

This repository intentionally separates the core DMVPN learning objective from the IPsec security extension.

## 21. Learning Outcomes

After completing this lab, you should be able to explain:

- What DMVPN solves
- Why mGRE is used
- How NHRP works
- How a spoke registers with the hub
- What an NHRP NHS is
- Why Phase 1 is hub-centric
- How Phase 2 creates direct spoke-to-spoke communication
- Why EIGRP next-hop preservation matters in Phase 2
- How Phase 3 uses NHRP redirect and shortcut
- How to verify DMVPN behavior
- How to troubleshoot NHRP, EIGRP and tunnel problems

## 22. Author

**Sholeh Abaszadeh**

Cisco Networking / CCNA / CCNP-Level Lab Practice

GitHub:

`https://github.com/abaszadehshole4-maker`
