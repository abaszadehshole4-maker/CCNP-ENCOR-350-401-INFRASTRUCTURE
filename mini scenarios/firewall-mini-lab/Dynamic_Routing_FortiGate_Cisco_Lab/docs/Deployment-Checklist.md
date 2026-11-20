# Deployment and Verification Checklist

## Before configuration
- [ ] Save / back up existing FortiGate configuration.
- [ ] Confirm FortiGate VM interface names; keep port1 management intact.
- [ ] Confirm Cisco router and switch interface names; adapt if needed.
- [ ] Build the EVE-NG links using topology.png.
- [ ] Confirm all lab IP ranges are isolated from production networks.

## Build
- [ ] SW-LAN: VLAN 10, VLAN 20, trunk and access ports.
- [ ] CORE-R1: transit, subinterfaces, OSPF passive design.
- [ ] ISP-R2: transit, Loopback0, eBGP and default-originate.
- [ ] FortiGate: port2, port3, firewall objects/policy, OSPF, BGP.
- [ ] VPCS: static addressing and default gateways.

## Verification gates
- [ ] PC-USER pings 10.10.10.1.
- [ ] PC-SERVER pings 10.10.20.1.
- [ ] CORE-R1 and FortiGate OSPF adjacency is FULL.
- [ ] FortiGate learns both LAN prefixes through OSPF.
- [ ] FortiGate and ISP BGP neighbor is Established.
- [ ] FortiGate learns 0.0.0.0/0 and 203.0.113.1/32 through BGP.
- [ ] ISP learns both LAN /24s through BGP.
- [ ] CORE-R1 learns the OSPF external default.
- [ ] Both VPCS clients ping 203.0.113.1.
- [ ] Optional prefix-list filter test and recovery complete.
- [ ] OSPF and BGP failure/recovery exercises complete.

## Documentation for a portfolio post
- [ ] Capture the topology screenshot.
- [ ] Capture OSPF neighbor FULL.
- [ ] Capture BGP summary Established.
- [ ] Capture FortiGate route table showing OSPF and BGP routes.
- [ ] Capture ISP BGP table showing both LAN routes.
- [ ] Capture successful client pings to 203.0.113.1.
- [ ] Remove pre-shared secrets and real public addressing from screenshots/configs before publishing.
