# GRE Explanations

## What is GRE?

GRE (Generic Routing Encapsulation) creates a logical tunnel between two routers. A packet from one LAN can be encapsulated in a GRE packet and transported across an IP network.

## Underlay vs Overlay

**Underlay:** The physical IP network used to reach the GRE endpoints.

- RouterA G0/0: `10.10.10.2`
- RouterB G0/0: `10.10.20.2`

**Overlay:** The logical GRE tunnel.

- RouterA Tunnel1: `192.168.100.1/30`
- RouterB Tunnel1: `192.168.100.2/30`

## Key Commands

### `tunnel source GigabitEthernet0/0`

Uses the physical interface as the source of GRE packets. The lab specifically requires an interface rather than an IP address.

### `tunnel destination 10.10.20.2`

Defines the remote physical GRE endpoint.

### `tunnel mode gre ip`

Uses GRE to encapsulate IP packets.

### `ip route 192.168.2.0 255.255.255.0 192.168.100.2`

Tells RouterA to send traffic for Host2's LAN to RouterB through the GRE tunnel. The next hop is explicitly the tunnel IP address.

## Why a /30 for the Tunnel?

A `/30` provides four addresses:
- Network: `192.168.100.0`
- RouterA: `192.168.100.1`
- RouterB: `192.168.100.2`
- Broadcast: `192.168.100.3`

This is a common point-to-point tunnel addressing scheme.

## Important Note

GRE itself does not encrypt traffic. For confidentiality, GRE can be combined with IPsec.
