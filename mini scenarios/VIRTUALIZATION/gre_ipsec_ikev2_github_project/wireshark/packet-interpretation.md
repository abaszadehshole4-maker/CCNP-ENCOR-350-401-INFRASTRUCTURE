# Packet interpretation notes

## IKEv2 — UDP/500

IKEv2 negotiates the security association and authenticates the peers. If you want the initial handshake in the capture, start capturing before the tunnel is brought up or before the negotiation is triggered. If the session is already established, the display filter `udp.port == 500` can legitimately show no packets until new negotiation/rekey activity occurs.

## ESP — IP protocol 50

ESP carries the protected GRE payload between the underlay endpoints. When ESP is not UDP-encapsulated, use `esp` or capture filter `ip proto 50`. The inner LAN packet is encrypted, so a standard underlay capture won't normally reveal inner OSPF headers or GRE separately.

## NAT-T — UDP/4500

When NAT Traversal is negotiated, ESP can be encapsulated in UDP port 4500. This lab has no NAT device in the basic topology, so UDP/4500 may not appear.

## GRE and OSPF

GRE is the tunnel encapsulation. OSPF is the routing protocol running across Tunnel0. In the intended protected design, their inner packets are carried inside ESP on the underlay. To inspect GRE/OSPF directly, capture at a point where packets are visible before IPsec encryption or on a supported tunnel interface/capture point.

## CLI evidence to pair with Wireshark

- `show crypto ikev2 sa` — peer IKEv2 session state.
- `show crypto ipsec sa` — IPsec SAs, encapsulation/decapsulation counters.
- `show ip ospf neighbor` — routing adjacency over the tunnel.
- `show ip route ospf` — routes learned from the other side.

Packet visibility depends on capture placement, image behavior, and Wireshark version. Document exactly where you captured each file.
