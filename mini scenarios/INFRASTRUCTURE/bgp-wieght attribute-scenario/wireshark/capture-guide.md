# Wireshark Capture Guide for BGP

BGP uses TCP port **179**. Unlike IKE/IPsec, you normally inspect a TCP session plus BGP OPEN, KEEPALIVE, UPDATE, and NOTIFICATION messages.

## Where to capture

- Capture on the RouterA–RouterB link to observe the iBGP TCP session between `1.1.1.1` and `2.2.2.2` (the packet's source/destination are loopbacks at IP level, carried on that physical link).
- Capture on the RouterB–RouterC link to observe the eBGP session between `2.2.2.2` and `3.3.3.3`.
- Capture on the RouterC–RouterD link to observe the iBGP session between `3.3.3.3` and `4.4.4.4`.
- In EVE-NG, start capture on the specific link in the topology. Start before bringing up BGP if you want to see session setup; an already-established TCP/BGP session may not repeat the OPEN exchange immediately.

## Display filters (apply after capture starts)

| What to inspect | Display filter |
|---|---|
| All BGP packets | `bgp` |
| BGP over TCP port 179 | `tcp.port == 179` |
| TCP handshake and session to RouterC loopback | `ip.addr == 2.2.2.2 && ip.addr == 3.3.3.3 && tcp.port == 179` |
| iBGP RouterA–RouterB | `ip.addr == 1.1.1.1 && ip.addr == 2.2.2.2 && tcp.port == 179` |
| iBGP RouterC–RouterD | `ip.addr == 3.3.3.3 && ip.addr == 4.4.4.4 && tcp.port == 179` |
| BGP UPDATE messages (if field supported) | `bgp.type == 2` |
| TCP SYN packets | `tcp.flags.syn == 1` |
| TCP retransmissions | `tcp.analysis.retransmission` |

Field names for BGP message type can vary between Wireshark versions. If `bgp.type == 2` is rejected, start with `bgp`, expand the BGP protocol tree, and inspect the Message Type field.

## Capture filters (set before capture starts)

| Purpose | Capture filter |
|---|---|
| BGP only | `tcp port 179` |
| BGP and ICMP for troubleshooting | `tcp port 179 or icmp` |

Capture filters use libpcap syntax and are not the same as display filters. If you're not sure, capture all traffic on the lab link and filter afterward.

## See an UPDATE message

1. Start capture before establishing the BGP neighbor session, or keep capturing and trigger a route-policy/network change in the lab.
2. Use display filter `bgp`.
3. Select a BGP UPDATE and expand its withdrawn routes, path attributes, and network-layer reachability information (NLRI).
4. To study the Weight demo, trigger a controlled update/refresh after the route-map policy is active. Note: Cisco Weight is local to RouterB and **is not carried as a standard BGP path attribute in UPDATEs**. You can see the advertised prefix and attributes such as AS_PATH/NEXT_HOP in packets, but verify Weight with RouterB CLI (`show ip bgp 10.99.99.0`).

## Save evidence

Save captures as `.pcapng` and screenshots as `.png`. Review them before uploading to GitHub; packet captures can include lab addressing and other information. Don't claim a capture shows Weight itself—Weight is locally significant and not advertised to neighbors.
