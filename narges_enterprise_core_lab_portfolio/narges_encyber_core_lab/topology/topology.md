# Topology — Enterprise Core Resilience & Operations Lab

```text
                              +----------------+
                              |      ISP       |
                              | Lo0 198.18.0.1 |
                              +-------+--------+
                                      |
                              203.0.113.0/30
                                      |
                                   +--+--+
                                   | EDGE|
                                   +--+--+
                                      |
                              10.255.0.0/30
                                      |
                                   +--+--+
                                   | CORE |
                                   +--+--+
                                    /   \
                           .4/30    /     \   .8/30
                                  /       \
                               +--+--+   +--+--+
                               |DIST1|===|DIST2|
                               +--+--+   +--+--+
                                  |          |
                                  +----+-----+
                                       |
                         +-------------+--------------+
                         |                            |
                      +--+--+                      +--+--+
                      |ACC1 |======================|ACC2 |
                      +--+--+      Po12            +--+--+
                         |                            |
                         +------------+---------------+
                                      |
                                   MGMT-SW
                                      |
                                    MGMT1

DIST1/DIST2: L3 distribution + HSRPv2
ACC1/ACC2: L2 access
MGMT1: RADIUS, NTP, syslog, SNMP traps, NetFlow collector
PC2/PC3/PC4 attach to ACC access ports for VLAN 110/120/130
```

## Interface map

| Node | Interface | Connected to | Address |
|---|---|---|---|
| ISP | E0/0 | EDGE E0/0 | 203.0.113.1/30 |
| ISP | Lo0 | - | 198.18.0.1/32 |
| EDGE | E0/0 | ISP E0/0 | 203.0.113.2/30 |
| EDGE | E0/1 | CORE E0/0 | 10.255.0.1/30 |
| EDGE | Lo0 | - | 10.255.255.1/32 |
| CORE | E0/0 | EDGE E0/1 | 10.255.0.2/30 |
| CORE | E0/1 | DIST1 E0/0 | 10.255.0.5/30 |
| CORE | E0/2 | DIST2 E0/0 | 10.255.0.9/30 |
| CORE | Lo0 | - | 10.255.255.2/32 |
| DIST1 | E0/0 | CORE E0/1 | 10.255.0.6/30 |
| DIST1 | E0/1 | DIST2 E0/1 | 10.255.0.13/30 |
| DIST1 | E1/0 | ACC1 trunk | 802.1Q |
| DIST2 | E0/0 | CORE E0/2 | 10.255.0.10/30 |
| DIST2 | E0/1 | DIST1 E0/1 | 10.255.0.14/30 |
| DIST2 | E1/0 | ACC2 trunk | 802.1Q |
| DIST1 | VLAN110/120/130 | HSRP | .1/24 |
| DIST2 | VLAN110/120/130 | HSRP | .2/24 |
| MGMT-SW | Gi0/1 | MGMT1 | 10.110.30.50/24 |
