# Portfolio Project Summary

## Project
Enterprise Core Resilience & Operations Lab

## Creator
NARGES

## What this demonstrates

This project demonstrates an independently designed Cisco enterprise lab built in EVE-NG. It combines routing, first-hop redundancy, routing-policy control, and network-management services in one reproducible scenario.

### Routing

- OSPFv2 Area 0
- OSPFv3 IPv6
- eBGP / MP-BGP at the enterprise edge
- Default-route propagation from EDGE into OSPF
- Static-route redistribution controlled by prefix-list and route-map
- Optional inbound OSPF route filtering with distribute-list

### High availability

- HSRPv2
- IP SLA
- Object tracking
- STP root placement
- LACP EtherChannel

### Operations

- RADIUS / AAA
- NTP
- Syslog
- SNMPv2c traps
- Flexible NetFlow / NetFlow v9 export

## Recommended screenshots for a GitHub portfolio

1. OSPF neighbors and routing table on CORE.
2. BGP summary on EDGE and ISP.
3. HSRP state before and after shutting an uplink.
4. IP SLA and track state during failure.
5. Prefix-list and route-map counters.
6. OSPF database compared with the RIB after a distribute-list filter.
7. MGMT1 receiving syslog and SNMP traps.
8. NetFlow collector showing exporter traffic.
