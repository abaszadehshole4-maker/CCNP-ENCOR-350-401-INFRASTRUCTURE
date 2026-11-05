# Wireshark filters for HSRP, STP and port-security testing

Capture on a link where the relevant frames are visible. In EVE-NG, start capture on the DSW–ASW trunk or the DSW1–DSW2 trunk for VLAN-tagged STP and HSRP control traffic.

## Display filters

| Purpose | Filter |
|---|---|
| Spanning Tree Protocol BPDUs | `stp` |
| HSRP dissector | `hsrp` |
| HSRP UDP traffic | `udp.port == 1985` |
| HSRP multicast to 224.0.0.2 (commonly HSRPv1) | `ip.dst == 224.0.0.2` |
| HSRPv2 multicast to 224.0.0.102 | `ip.dst == 224.0.0.102` |
| ARP for host/gateway resolution | `arp` |
| ICMP connectivity tests | `icmp` |
| VLAN-tagged Ethernet frames | `vlan` |

Filter fields can vary with Wireshark version and packet decoding; if a dissector filter shows nothing, use `udp.port == 1985`, `stp`, or open packet details and check the decoded protocol.

## Capture filters (before capture)

- STP BPDUs: `stp`
- HSRP UDP: `udp port 1985`
- ARP and ICMP: `arp or icmp`

Capture filters use libpcap syntax; display filters use Wireshark's display-filter syntax.

## Capture procedure

1. Start capture before bringing up links or before generating test traffic.
2. Use `stp` to observe BPDUs and changes as links converge.
3. Use `hsrp` or `udp.port == 1985` to look for hello/state activity.
4. Generate host pings and use `icmp` / `arp` to observe endpoint traffic and gateway resolution.
5. Save the genuine file as `.pcapng` and place it in `evidence/`.

Port-security enforcement is a local switch function, not a dedicated network protocol. A capture may show frames with a new source MAC arriving at the access port, but the violation counter/log is usually best verified directly on the switch with `show port-security interface ...`.
