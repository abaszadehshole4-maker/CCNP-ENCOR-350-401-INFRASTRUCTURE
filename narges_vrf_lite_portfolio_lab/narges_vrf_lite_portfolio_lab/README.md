# Multi-VRF Enterprise Segmentation Lab

**Creator:** NARGES

## Portfolio project

This is an independently authored EVE-NG networking lab focused on **VRF-Lite**, **802.1Q router-on-a-stick**, **IPv4/IPv6 static routing**, Layer-2 VLANs, EtherChannel, PortFast, and management-plane access control.

The design is intentionally original: it uses a new topology, new addressing plan, new device/VRF names, and its own task sequence.

## Scenario

A small enterprise has two isolated user groups:

- **FINANCE** users
- **ENGINEERING** users

Both groups share the same WAN infrastructure, but their traffic must remain separated by VRF-Lite from the access switches through three routers.

Required outcome:

1. Each user group has end-to-end IPv4 and IPv6 connectivity between its own sites.
2. FINANCE must not communicate with ENGINEERING.
3. The routed links between CORE-GW, TRANSIT, and REMOTE-GW use VRF-aware subinterfaces.
4. VLAN 110 is used for FINANCE and VLAN 120 for ENGINEERING.
5. Access-switch uplinks use 802.1Q trunks.
6. A selected switch pair uses LACP EtherChannel.
7. User-facing access ports use PortFast.
8. All Cisco nodes have local AAA authentication and an encrypted privileged secret.

## Topology

```text
                         TRANSIT
                   +----------------+
                   |                |
              .110 |                | .120
                   |                |
                   +--------+-------+
                            |
                    +-------+-------+
                    |               |
                 CORE-GW         REMOTE-GW
                /        \       /        \
          VLAN110       VLAN120 VLAN110    VLAN120
            |              |      |            |
         FIN-CLIENT1   ENG-CLIENT1 FIN-CLIENT2 ENG-CLIENT2
            |              |      |            |
         DIST-A         DIST-A  DIST-B       ACC-B
```

The actual EVE-NG topology includes three routers and three switches. The `TOPOLOGY.md` file provides the exact cabling and port map.

## VRF policy

| VRF | VLAN | Purpose | IPv4 |
|---|---:|---|---|
| FINANCE | 110 | Finance users | 10.44.110.0/24 |
| ENGINEERING | 120 | Engineering users | 10.44.120.0/24 |

IPv6:

- FINANCE: `2001:db8:44:110::/64`
- ENGINEERING: `2001:db8:44:120::/64`

## Addressing philosophy

A fresh RFC1918/RFC5737-style lab addressing plan is used instead of reproducing the source addressing table. Point-to-point transit links use /30 networks; client VLANs use /24 networks; IPv6 user segments use /64 prefixes.

## Lab tasks

The detailed task sheet is in `docs/tasks.md`.

## Build order

### Part 1 — Base configuration

1. Deploy nodes from `topology/vrf_lite_portfolio.unl`.
2. Configure hostnames.
3. Configure interfaces and IPv4/IPv6 addresses.
4. Save configurations.

### Part 2 — VRF-Lite

1. Create `FINANCE` and `ENGINEERING` VRFs on each router.
2. Bind the VLAN subinterfaces to the appropriate VRF.
3. Configure 802.1Q encapsulation.
4. Configure IPv4/IPv6 addresses.
5. Enable all routed interfaces.

### Part 3 — Routing

1. Configure VRF-specific static routes.
2. Use default routes on the edge routers.
3. Use explicit routes on the transit router.
4. Verify each VRF independently.

### Part 4 — Layer 2

1. Configure VLAN 110 and VLAN 120.
2. Configure trunks.
3. Configure LACP EtherChannel.
4. Configure access ports.
5. Enable PortFast on host ports.

### Part 5 — Secure access

1. Configure a local privilege-15 user.
2. Configure SCRYPT enable secret.
3. Enable AAA authentication using the local database.
4. Verify console/VTY authentication.

## Key verification commands

```text
show vrf
show vrf interfaces
show ip route vrf FINANCE
show ip route vrf ENGINEERING
show ipv6 route vrf FINANCE
show ipv6 route vrf ENGINEERING
show ip interface brief
show ipv6 interface brief
show interfaces trunk
show etherchannel summary
show spanning-tree vlan 110
show spanning-tree vlan 120
show running-config | section aaa
show running-config | include username
```

## Isolation test

A successful lab must demonstrate:

```text
FINANCE -> FINANCE       PASS
ENGINEERING -> ENGINEERING PASS
FINANCE -> ENGINEERING   FAIL (expected)
ENGINEERING -> FINANCE   FAIL (expected)
```

Use the exact source/destination pairs in `verification/commands.txt`.

## Portfolio notes

This repository is intended as a personal lab/portfolio project. It does not include proprietary answer scripts or copied chapter text. The documentation is written specifically for this implementation.

**Creator:** NARGES
