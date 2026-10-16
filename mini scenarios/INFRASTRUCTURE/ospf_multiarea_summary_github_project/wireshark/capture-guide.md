# Wireshark: capture OSPF packets

## Where to capture

- Capture the shared `10.100.100.0/24` backbone link to see OSPF between P1R1 and P2R1.
- Capture a serial link to see OSPF between P1R1–P1R2 or P2R1–P2R2.
- Capture one of the LAN links to see OSPF between P1R2–P1R3 or P2R2–P2R3.

Start the EVE-NG packet capture on the selected link **before** bringing up the adjacency or before bouncing an interface. To see fresh Hellos, restarting a whole router is unnecessary; depending on the situation you can shut/no shut a lab interface after planning for the adjacency to reform.

## Display filters

Enter these in Wireshark's display-filter bar and press Enter:

| Purpose | Filter |
|---|---|
| All OSPF packets | `ospf` |
| OSPF Hello | `ospf.msg == 1` |
| Database Description | `ospf.msg == 2` |
| Link-State Request | `ospf.msg == 3` |
| Link-State Update | `ospf.msg == 4` |
| Link-State Acknowledgment | `ospf.msg == 5` |
| Traffic between two backbone routers | `ip.addr == 10.100.100.1 && ip.addr == 10.100.100.2 && ospf` |
| Left serial link | `ip.addr == 192.168.1.33 && ip.addr == 192.168.1.34 && ospf` |
| Right serial link | `ip.addr == 192.168.2.33 && ip.addr == 192.168.2.34 && ospf` |

## Capture filters (set before starting capture)

Capture filters use libpcap syntax, not display-filter syntax:

- OSPF only: `ip proto 89`
- OSPF on a link between the backbone addresses: `host 10.100.100.1 or host 10.100.100.2` (this includes other IP protocols on those hosts; use `ip proto 89` for OSPF only)

## What you should observe

- Hello packets are multicast to `224.0.0.5` on typical broadcast links.
- The two routers on each segment should discover each other and form adjacencies.
- Link-State Updates carry LSAs; summary LSAs help propagate inter-area reachability.
- OSPF does not use TCP or UDP; it is IP protocol 89.

For packet evidence, save a `.pcapng` file and add a screenshot of a representative OSPF packet. Do not add simulated or fabricated captures to the repository.
