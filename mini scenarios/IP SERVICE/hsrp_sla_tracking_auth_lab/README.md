# HSRP Failover Lab: IP SLA, Object Tracking, and Authentication

A CCNP-level Cisco IOS lab demonstrating HSRP gateway redundancy, IP SLA reachability checks, object tracking, priority decrement, preemption, and HSRP authentication.

> **Platform note:** These examples target Cisco IOS/IOS XE syntax commonly used on IOSv/CSR1000v/Catalyst-style labs. Exact interface names and HSRP authentication syntax vary by image and release. Adapt interface IDs to your simulator/device. Test in a lab, not on a production network.

## Learning objectives

- Configure HSRP on two routers sharing a client VLAN.
- Use HSRP version 2 and a virtual default gateway.
- Probe an upstream IP with IP SLA.
- Tie the SLA result to an object-tracking object.
- Decrease the preferred router's HSRP priority when the probe fails.
- Enable preemption so the healthier router can take over.
- Configure matching HSRP authentication and verify behavior.
- Identify HSRP hello packets in Wireshark.

## Topology

See [`docs/topology.png`](docs/topology.png) and [`docs/topology.svg`](docs/topology.svg).

| Device | Interface | Address | Purpose |
|---|---|---:|---|
| R1 | G0/0 (LAN) | 192.168.10.2/24 | Preferred HSRP router |
| R1 | G0/1 (WAN) | 10.0.1.2/30 | Upstream path |
| R2 | G0/0 (LAN) | 192.168.10.3/24 | Standby / backup router |
| R2 | G0/1 (WAN) | 10.0.2.2/30 | Upstream path |
| SW1 | VLAN 10 | L2 segment | Connects R1, R2, and client |
| ISP | G0/0 | 10.0.1.1/30 | R1 upstream next hop |
| ISP | G0/1 | 10.0.2.1/30 | R2 upstream next hop |
| ISP | Loopback0 | 203.0.113.1/32 | IP SLA target |
| Client | NIC | 192.168.10.100/24 | Default gateway 192.168.10.1 |

The ISP router has connected routes to both WAN links and its loopback. In this simple lab, each HSRP router can reach the SLA target through its own WAN interface. The WAN links are separate routed links; they do not need to be in the HSRP LAN VLAN.

## Addressing and behavior

- HSRP group: `10`
- HSRP virtual IP: `192.168.10.1`
- HSRP version: `2`
- R1 priority: `110`
- R2 priority: `100`
- R1 tracked-object decrement: `30`
- If R1's SLA fails, its effective priority becomes `80`, allowing R2 (priority 100) to become Active.
- `preempt` allows R1 to reclaim Active status after its SLA recovers, once its priority is again higher.
- HSRP authentication is configured on both routers with the same lab-only key string.

## Files

- `configs/R1.txt` — preferred gateway, SLA, tracking, authentication
- `configs/R2.txt` — backup gateway, authentication
- `configs/ISP.txt` — upstream test router and SLA target
- `configs/SW1.txt` — optional Layer 2 switch configuration
- `configs/CLIENT.txt` — client addressing guidance (not IOS config)
- `docs/topology.png` / `docs/topology.svg` — topology diagram
- `docs/verification-and-tests.md` — commands and test procedure
- `wireshark/hsrp_capture_guide.md` — display filters and expected fields
- `wireshark/hsrp_hello_expected.png` — illustrative packet-list/details mockup
- `wireshark/hsrp_failover_expected.png` — illustrative failover timeline

## Build the lab

1. Create the devices in Packet Tracer, CML, EVE-NG, GNS3, or physical lab equipment.
2. Connect R1 G0/0, R2 G0/0, and the client to SW1 access ports in VLAN 10.
3. Connect R1 G0/1 to ISP G0/0 and R2 G0/1 to ISP G0/1.
4. Apply the configs, adapting interface names as required.
5. Configure the client with `192.168.10.100/24`, gateway `192.168.10.1`.
6. Verify HSRP is stable before inducing a failure.

## Important lab notes

- HSRP authentication is not encryption. Treat the configured key as a lab secret and do not reuse production credentials.
- HSRP authentication support and exact command syntax depend on IOS/IOS XE version. If `standby 10 authentication md5 key-string ...` is rejected, check the feature syntax for your image; do not silently remove authentication from a real deployment.
- To test SLA failure without physically disconnecting R1's LAN, temporarily block ICMP from R1's WAN path to `203.0.113.1` or shut the relevant ISP-facing interface. If you shut R1's WAN interface itself, the SLA should fail too.
- The SLA target should represent a meaningful upstream dependency. A single ICMP target can be misleading if ICMP is filtered or the target is unavailable for unrelated reasons.
- This package includes **illustrative Wireshark-style screenshots**, not a live packet capture from your equipment. Capture your own traffic for a portfolio submission and replace these images with genuine screenshots if possible.
