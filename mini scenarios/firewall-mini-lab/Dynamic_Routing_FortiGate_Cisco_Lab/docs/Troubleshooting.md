# Troubleshooting Workflow

Use an evidence-first sequence. Avoid changing multiple routing variables at once.

## 1. Physical and interface layer
- FortiGate: `get system interface physical`, `show system interface`
- Cisco: `show ip interface brief`, `show interfaces status`
- Confirm links are up/up, correct cabling, correct IP/mask, no duplicate IPs.

## 2. OSPF control plane
- FortiGate: `get router info ospf neighbor`, `get router info ospf interface`, `get router info ospf database`
- Cisco: `show ip ospf neighbor`, `show ip ospf interface brief`, `show ip protocols`
- Check area, timers, network type, authentication (none in this lab), MTU, passive-interface and router ID uniqueness.
- FULL is expected for this point-to-point link.

## 3. BGP control plane
- FortiGate: `get router info bgp summary`, `get router info bgp neighbors`, `get router info bgp neighbors 198.51.100.1 advertised-routes`
- Cisco ISP: `show ip bgp summary`, `show ip bgp`, `show ip bgp neighbors 198.51.100.2`
- Check TCP/IP reachability, remote AS, neighbor address, local AS, route advertisement, and filters.
- Established is the expected BGP state.

## 4. Routing information base (RIB)
- FortiGate: `get router info routing-table all`, `get router info routing-table ospf`, `get router info routing-table bgp`
- Cisco core/ISP: `show ip route`, `show ip route ospf`, `show ip route bgp`
- Confirm the route exists, the next hop is reachable, and the route is installed.
- Longest-prefix match selects the most specific matching prefix. Administrative distance and protocol metrics help select between competing routes for the same prefix; they are not a substitute for longest-prefix match.

## 5. Data plane and security policy
- VPCS: `show ip`, `ping 10.10.10.1`, `ping 203.0.113.1`
- FortiGate: `show firewall policy`, `diagnose sys session list`, `diagnose sniffer packet any 'host 203.0.113.1' 4 0 l`
- The lab uses no NAT so the ISP's BGP-learned return routes are part of the learning objective.

## 6. Controlled debug
Use debug only when normal show commands and logs do not explain the fault. Limit filters and duration on any production firewall. This lab should be conducted only on isolated EVE-NG lab nodes.
