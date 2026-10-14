# Wireshark filters for IKEv2, IPsec, GRE, and OSPF

## Display filters (apply after capture starts)

| Goal | Display filter |
|---|---|
| IKE traffic using UDP 500 | `udp.port == 500` |
| IKEv2 protocol dissector | `ikev2` |
| ESP | `esp` |
| GRE | `gre` |
| OSPF | `ospf` |
| NAT Traversal / UDP 4500 | `udp.port == 4500` |
| Ping / ICMP | `icmp` |
| All traffic between the underlay endpoints | `ip.addr == 203.0.113.1 && ip.addr == 203.0.113.2` |
| IKE between the underlay endpoints | `ip.addr == 203.0.113.1 && ip.addr == 203.0.113.2 && udp.port == 500` |
| ESP between the underlay endpoints | `ip.addr == 203.0.113.1 && ip.addr == 203.0.113.2 && esp` |
| Combine ESP and IKE packets | `(esp) || (udp.port == 500) || (udp.port == 4500)` |

## Capture filters (set before pressing Start)

| Goal | Capture filter |
|---|---|
| IKE | `udp port 500` |
| NAT-T | `udp port 4500` |
| ESP | `ip proto 50` |
| GRE | `ip proto 47` |
| OSPF | `ip proto 89` |
| IKE + NAT-T + ESP | `udp port 500 or udp port 4500 or ip proto 50` |
| IKE + NAT-T + ESP + GRE + OSPF | `udp port 500 or udp port 4500 or ip proto 50 or ip proto 47 or ip proto 89` |

## Recommended workflow

1. In EVE-NG, right-click the R1–R2 underlay link and start a packet capture, or select the actual host interface receiving that link's packets.
2. Start capture **before** you trigger IKE negotiation if you want to record the handshake.
3. To see IKE, use display filter `udp.port == 500` (not `UDP==500`).
4. After tunnel establishment, ping across the tunnel or send LAN-to-LAN traffic.
5. Use display filter `esp` to inspect protected underlay packets.
6. Use `udp.port == 4500` if NAT Traversal is used.
7. On the protected underlay, GRE and OSPF are generally inside ESP and not independently decoded. Capture on a tunnel-side/pre-IPsec point if you specifically need to inspect inner GRE/OSPF.
8. Stop capture and save as `.pcapng`.

**Do not confuse the two filter bars:** capture filters are set before capturing and decide which packets are recorded; display filters are applied after capture and only affect what is shown.
