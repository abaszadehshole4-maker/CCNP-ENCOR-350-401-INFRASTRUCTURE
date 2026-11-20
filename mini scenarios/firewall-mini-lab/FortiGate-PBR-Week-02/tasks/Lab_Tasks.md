# Lab Tasks - FortiGate Policy-Based Routing

Complete the tasks before opening `solutions/Solutions.md`.

1. **Build the topology.** Add the FortiGate, three IOSv routers, one IOSvL2 switch and two VPCS hosts. Cable according to `topology/README.md`.
2. **Configure base interfaces.** Apply the addressing plan and bring all Cisco interfaces up. Set the two VPCS addresses and default gateways.
3. **Prove underlay reachability.** From the FortiGate, ping both directly connected ISP next hops. From each ISP router, ping its Core-facing next hop. From the Core router, ping both FortiGate WAN IPs using the return routes.
4. **Configure ordinary routing.** Add one FortiGate default route through ISP-A/WAN1. Confirm it is active.
5. **Configure the PBR rule.** Match ingress port1, source PC-PBR 10.10.10.10/32 and destination Server-A 192.0.2.10/32. Forward to 198.51.100.1 through port3.
6. **Configure firewall policies and NAT.** Permit the matching PC1-to-Server-A flow out port3 and ordinary traffic out port2. Enable NAT on both lab policies.
7. **Verify the matching flow.** Ping 192.0.2.10 from PC-PBR. Confirm the egress is WAN2/port3 using the policy-route list, route match diagnostic, session table or sniffer.
8. **Verify a non-matching flow.** Ping 192.0.2.10 from PC-DEFAULT. Confirm it uses WAN1/port2.
9. **Verify destination specificity.** Ping 192.0.2.20 from PC-PBR. It does not match the PBR destination and should use WAN1/port2.
10. **Change the PBR scope.** Temporarily change the source match to the entire LAN `10.10.10.0/255.255.255.0`. Predict and verify the effect. Restore the host-specific rule afterward.
11. **Add a protocol condition.** In a controlled test, configure a second PBR entry for a chosen TCP/UDP protocol and port, keeping it above any broader matching rule. Explain why ordering matters. Remove it after testing.
12. **Troubleshoot a deliberate failure.** Change the policy-route gateway to an incorrect next hop or shut the WAN2-facing link. Identify why the policy route cannot forward and restore the correct gateway/link.

## Success criteria
- PC-PBR to 192.0.2.10 exits port3/WAN2.
- PC-DEFAULT to 192.0.2.10 exits port2/WAN1.
- PC-PBR to 192.0.2.20 exits port2/WAN1.
- Firewall policies match the actual egress interface and apply NAT.
- The learner can explain that PBR chooses a forwarding path; it does not itself permit traffic through the firewall.
