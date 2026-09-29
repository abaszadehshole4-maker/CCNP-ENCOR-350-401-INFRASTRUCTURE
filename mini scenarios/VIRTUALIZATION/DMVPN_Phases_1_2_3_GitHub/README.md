# Cisco DMVPN Phases 1, 2 and 3 — EIGRP

**Creator:** Sholeh Abaszadeh

This GitHub lab demonstrates Cisco DMVPN Phase 1, Phase 2 and Phase 3 using EIGRP, with separate configurations, topology notes, and verification/troubleshooting material.

## Lab addressing

### Underlay / NBMA
| Device | NBMA / Underlay |
|---|---|
| Hub R1 | 192.168.123.1/24 |
| Spoke R2 | 192.168.123.2/24 |
| Spoke R3 | 192.168.123.3/24 |

### DMVPN tunnel
| Device | Tunnel0 |
|---|---|
| Hub R1 | 172.16.123.1/24 |
| Spoke R2 | 172.16.123.2/24 |
| Spoke R3 | 172.16.123.3/24 |

### Loopbacks
- R1: 1.1.1.1/32
- R2: 2.2.2.2/32
- R3: 3.3.3.3/32

EIGRP AS: **123**

## Phase 1
Phase 1 uses a hub-and-spoke DMVPN design. The hub uses mGRE and dynamic NHRP registration, while spokes use static NHRP mappings to the hub.

Key characteristics:
- Hub: `tunnel mode gre multipoint`
- Spokes: hub NHRP mapping and NHS
- Spoke-to-spoke traffic is not the direct-routing objective of Phase 1.
- EIGRP can run over the DMVPN tunnel.

See `configuration/phase1/`.

## Phase 2
Phase 2 adds direct spoke-to-spoke routing.

Important EIGRP commands on the hub Tunnel0:
- `no ip split-horizon eigrp 123`
- `no ip next-hop-self eigrp 123`

These allow EIGRP routes learned from one spoke to be advertised through the same multipoint tunnel and preserve the remote spoke as the next hop.

See `configuration/phase2/`.

## Phase 3
Phase 3 uses NHRP redirect on the hub and NHRP shortcut on the spokes. This allows the hub to signal a better spoke-to-spoke path and the spokes to install a shortcut route.

Typical Phase 3 additions:
- Hub: `ip nhrp redirect`
- Spokes: `ip nhrp shortcut`

Phase 3 keeps the routing design scalable while allowing spoke-to-spoke traffic to establish a direct path after the initial forwarding/redirect process.

See `configuration/phase3/`.

## Verification

Common commands:

```text
show dmvpn
show ip nhrp
show ip nhrp detail
show ip eigrp neighbors
show ip route eigrp
show ip route
show ip interface tunnel 0
show interfaces tunnel 0
```

Connectivity tests:

```text
ping 172.16.123.1
ping 172.16.123.2
ping 172.16.123.3
ping 3.3.3.3 source loopback 0
traceroute 3.3.3.3 source loopback 0
```

For Wireshark in EVE-NG, capture the underlay/NBMA interface and filter for GRE and NHRP traffic. Useful filters include:

```text
gre
nhrp
ip.addr == 192.168.123.1
ip.addr == 192.168.123.2
```

## Troubleshooting checklist

1. Confirm all underlay interfaces are up.
2. Confirm Tunnel0 source and tunnel mode.
3. Check `show dmvpn` on the hub and spokes.
4. Check NHRP mappings with `show ip nhrp`.
5. Check EIGRP neighbors.
6. Check EIGRP routes.
7. For Phase 2, verify split horizon and next-hop-self settings.
8. For Phase 3, verify NHRP redirect/shortcut.
9. Generate traffic before expecting dynamic NHRP shortcut entries.

## Source basis

The Phase 2 EIGRP material in this repository is based on the supplied study document. The document specifically demonstrates:
- EIGRP over DMVPN
- EIGRP split horizon
- EIGRP next-hop behavior
- `no ip split-horizon eigrp 123`
- `no ip next-hop-self eigrp 123`
- direct spoke-to-spoke routing

Phase 1 and Phase 3 are organized as a practical extension of the supplied Phase 2 lab; exact IOS behavior can vary by platform/image.
