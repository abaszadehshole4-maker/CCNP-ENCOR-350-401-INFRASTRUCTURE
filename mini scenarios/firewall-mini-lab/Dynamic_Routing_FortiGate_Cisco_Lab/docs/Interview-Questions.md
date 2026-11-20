# Dynamic Routing - Job-Market Interview Notes

## OSPF
**What is OSPF?** An interior gateway link-state protocol. Routers exchange LSAs, build a link-state database, run SPF, and install best paths. It is commonly used within an enterprise autonomous system.

**Why Area 0?** Area 0 is the OSPF backbone. This small lab uses only Area 0 to avoid inter-area complexity.

**What is an OSPF neighbor adjacency?** A relationship through which routers exchange and synchronize link-state information. For this point-to-point link, the target state is FULL.

**Why passive interfaces?** A LAN can be advertised into OSPF without sending OSPF hellos to end hosts. In the lab, CORE-R1 makes its LAN subinterfaces passive and keeps only the FortiGate transit interface active for adjacency.

**What is OSPF cost?** A metric used by OSPF to choose a path. Lower total cost is preferred among OSPF candidate paths.

## BGP
**What is BGP?** A path-vector inter-domain routing protocol used to exchange reachability information between autonomous systems.

**What is eBGP vs iBGP?** eBGP exchanges routes between different AS numbers; iBGP exchanges routes within the same AS.

**What is an AS number?** An identifier for a routing domain under a common routing policy. This lab uses private ASNs 65010 and 65000.

**What is AS_PATH?** A BGP path attribute listing ASNs a route has traversed; it is one mechanism for loop prevention and path selection.

**What does a BGP network statement do?** It originates a specified prefix into BGP when a matching route exists in the local routing table. In this lab, FortiGate advertises OSPF-learned LAN prefixes by explicit statements.

**Why not redistribute everything?** Uncontrolled redistribution can leak unwanted routes, create feedback loops, and complicate policy. Prefer explicit prefixes and route maps/prefix filters where appropriate.

## OSPF + BGP integration
**What is an ASBR?** An autonomous system boundary router that exchanges routes between OSPF and another routing domain/protocol. In this lab FortiGate is the edge and originates a BGP-learned default into OSPF.

**How does the default reach clients?** ISP sends default to FortiGate through eBGP. FortiGate installs it, then `default-information-originate enable` advertises it into OSPF. CORE-R1 installs an OSPF external default.

**Why is NAT disabled here?** To force the ISP to learn the private LAN routes via BGP and prove the return path. A production Internet firewall generally uses SNAT, but that is a separate NAT lab objective.

## Interview troubleshooting answer pattern
1. Confirm the symptom and affected source/destination.
2. Verify interfaces and addressing.
3. Check OSPF/BGP neighbor state.
4. Check whether the expected route is learned and installed.
5. Verify next-hop reachability and longest-prefix match.
6. Check firewall policy, session and logs.
7. Change one item, retest, and document root cause and rollback.
