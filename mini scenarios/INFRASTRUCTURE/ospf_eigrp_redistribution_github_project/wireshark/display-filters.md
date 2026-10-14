# Wireshark guide for EIGRP-to-OSPF redistribution

Redistribution is a router control-plane function. Wireshark can show routing protocol messages, but the routing table and LSDB are the best tools to prove which prefixes were redistributed.

## Display filters

| What to observe | Display filter |
|---|---|
| OSPF packets | `ospf` |
| EIGRP packets | `eigrp` |
| All traffic on the capture | Clear the display filter |
| Packets involving the R2-R3 OSPF link endpoints | `ip.addr == 10.0.23.2 && ip.addr == 10.0.23.3` |
| OSPF multicast destination | `ip.dst == 224.0.0.5 || ip.dst == 224.0.0.6` |

## Capture procedure

1. In EVE-NG, start capture on the R1-R2 link to see EIGRP packets, or the R2-R3 link to see OSPF packets.
2. Start capture before a routing adjacency is first established if you want to observe the initial neighbor formation. Otherwise, trigger a relevant change to produce new updates.
3. Apply `eigrp` on the R1-R2 segment and `ospf` on the R2-R3 segment.
4. Use CLI checks on R2/R3 to verify the redistribution policy and resulting routes; packet captures alone may not make the route-policy outcome obvious.

## Packet expectations

- EIGRP uses IP protocol 88; EIGRP hello and update activity can be seen on the R1-R2 link.
- OSPF uses IP protocol 89; OSPF hello and link-state update packets can be seen on the R2-R3 link.
- The prefix-list decision itself is not a separate packet. You prove it by comparing the EIGRP learned prefixes on R2 with OSPF external routes on R3.
