# Practical Tasks - Dynamic Routing Lab

Complete the tasks in order. Do not paste the complete solution immediately; first predict what should happen and then prove it using routing tables and protocol summaries.

## Task 1 - Build the physical/logical topology
Add FortiGate-EDGE, CORE-R1, ISP-R2, SW-LAN, PC-USER and PC-SERVER. Connect links using the README interface map. Create VLANs 10 and 20 on the switch.

**Expected:** all router-to-router links and switch ports are up; VLAN 10 and VLAN 20 exist.

## Task 2 - Configure the LAN clients and router-on-a-stick
Configure the CORE-R1 subinterfaces and VPCS addresses. Verify each PC can ping its default gateway.

**Expected:** PC-USER reaches 10.10.10.1; PC-SERVER reaches 10.10.20.1.

## Task 3 - Establish OSPF adjacency
Configure OSPF Area 0 between CORE-R1 and FortiGate. Use router IDs 10.255.0.2 and 10.255.0.1. Make the CORE-R1 LAN subinterfaces passive.

**Expected:** CORE-R1 and FortiGate show a FULL OSPF neighbor relationship.

## Task 4 - Verify OSPF LAN route learning
Confirm FortiGate learns 10.10.10.0/24 and 10.10.20.0/24 as OSPF routes. Check that neither VLAN has an unexpected OSPF neighbor.

**Expected:** the two LAN routes appear in the FortiGate routing table as OSPF routes.

## Task 5 - Establish eBGP
Configure FortiGate AS 65010 and ISP-R2 AS 65000. Use the directly connected 198.51.100.0/30 link.

**Expected:** BGP state is Established; FortiGate receives the ISP test loopback and default route.

## Task 6 - Advertise enterprise LAN routes to the ISP
Use the two FortiGate BGP network statements. Do not use unrestricted OSPF redistribution into BGP.

**Expected:** ISP-R2 learns 10.10.10.0/24 and 10.10.20.0/24 through BGP.

## Task 7 - Originate the BGP-learned default into OSPF
Enable FortiGate OSPF default-information-originate. Confirm the default route exists on FortiGate first.

**Expected:** CORE-R1 learns 0.0.0.0/0 as an OSPF external route.

## Task 8 - End-to-end verification
From both VPCS clients, ping 203.0.113.1. Check routing tables on all three Layer 3 devices.

**Expected:** both clients reach the ISP loopback without NAT; the return route is learned by ISP-R2 through BGP.

## Task 9 - Observe longest-prefix match
On FortiGate, compare the route to 203.0.113.1/32 with the default route 0.0.0.0/0.

**Expected:** the /32 route wins for 203.0.113.1 because longest-prefix match is evaluated before route preference between competing prefixes.

## Task 10 - Apply a BGP inbound prefix filter (optional)
On ISP-R2, accept only 10.10.10.0/24 from FortiGate. Observe that 10.10.20.0/24 disappears from ISP-R2's BGP/RIB. Remove the filter and verify that both routes return.

**Expected:** the filter affects only routes received from the FortiGate neighbor; the OSPF adjacency is unchanged.

## Task 11 - Simulate an OSPF failure
Shut down CORE-R1 Gi0/0. Observe the OSPF neighbor and FortiGate OSPF routes. Restore the interface.

**Expected:** OSPF goes down, internal prefixes are withdrawn from FortiGate, and BGP stops advertising prefixes that no longer exist in its routing table. After recovery, OSPF and BGP routes return.

## Task 12 - Simulate a BGP failure
Shut down the BGP neighbor on ISP-R2. Observe the FortiGate BGP table, default route, and OSPF default advertisement. Restore the BGP neighbor.

**Expected:** BGP routes disappear. With `default-information-originate enable`, FortiGate withdraws its OSPF default when it no longer has a qualifying default route. The default returns after BGP recovers.

## Task 13 - Troubleshoot deliberate mistakes
Try one at a time: wrong BGP remote AS, wrong OSPF area, mismatched OSPF hello/dead timer, incorrect BGP network mask, or missing FortiGate firewall policy.

**Expected:** identify the fault from evidence before correcting it. Record the exact command/output that proved the root cause.
