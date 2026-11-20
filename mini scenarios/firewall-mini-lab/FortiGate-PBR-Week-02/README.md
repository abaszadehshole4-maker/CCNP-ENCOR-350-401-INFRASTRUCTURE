# FortiGate Policy-Based Routing (PBR) - Week 02 Lab

A simple enterprise lab for learning IPv4 policy-based routing on FortiGate FortiOS 7.6.x. It demonstrates source-and-destination matching to steer one selected flow through WAN2 while ordinary traffic uses the default route through WAN1.

## Learning outcomes
- Explain how PBR differs from a static route and a firewall policy.
- Configure a default route for ordinary traffic.
- Create a policy route based on incoming interface, source IP and destination IP.
- Configure matching firewall policies and source NAT.
- Verify the selected egress path and troubleshoot a missing route or return path.

## Scenario
PC-PBR (10.10.10.10) to Server-A (192.0.2.10) must use WAN2/ISP-B. All nonmatching traffic uses the default route through WAN1/ISP-A. PC-PBR to Server-B (192.0.2.20) is deliberately nonmatching and therefore uses WAN1.

## Repository layout
```text
configs/          Complete configs for FGT, three IOSv routers, IOSvL2 switch, and both VPCS clients
addressing-plan.csv  Interface and host addressing table
node-inventory.csv  EVE-NG node/image inventory
topology/         PNG, SVG and DOT topology sources plus cabling notes
tasks/            Student tasks
solutions/        Worked solutions
verification/     Expected checks and packet capture commands
docs/             Editable Word guide
```

## EVE-NG node list
- FortiGate VM64 KVM, FortiOS 7.6.x (7.6.7 is the lab target build)
- Cisco IOSv routers x3
- Cisco IOSvL2 switch x1
- VPCS x2

Interface naming must match your imported images. If your FortiGate port numbering differs, adjust the `FGT-HQ.conf` interface references and all related policies/routes consistently.

## Build order
1. Add nodes and cable them using `topology/README.md`.
2. Configure switch, PCs and Cisco routers from `configs/`.
3. Configure FortiGate interfaces and verify both directly connected ISP gateways.
4. Configure the default static route through WAN1.
5. Configure policy route ID 10 for PC-PBR -> Server-A through WAN2.
6. Configure the two outbound firewall policies with NAT.
7. Run all items in `tasks/Lab_Tasks.md` and compare with `solutions/Solutions.md`.

## Key FortiGate commands
```fortios
get router info routing-table all
show router policy
diagnose firewall proute list
diagnose ip proute match 192.0.2.10 10.10.10.10 port1 1 0 0 0
diagnose sniffer packet port3 'host 192.0.2.10' 4 0 l
```

## Important concepts
- PBR matches traffic and chooses the forwarding gateway/interface before normal route-table lookup for that traffic. A policy route does **not** replace the firewall policy.
- A matching firewall policy is still required. The firewall policy must use the egress interface selected by PBR.
- The policy-route gateway must be reachable through an active route/interface. Here, ISP-B's gateway is directly connected on port3.
- Source NAT is enabled in both lab policies so the return traffic is directed to the same WAN address used by the outbound session. The Core router has return routes to both FortiGate WAN addresses.
- The example uses `service ALL` only to keep ping/traceroute tests straightforward in an isolated lab. Do not copy that service scope into production; restrict services and destinations.
- If you change a policy route during an active session, use a new flow or clear only the relevant test session. Existing sessions can retain their established path.
- This lab is not an SD-WAN lab. Do not configure SD-WAN simultaneously for the same traffic while learning regular `config router policy` behavior.

## Assumptions and safety
The configuration files assume a clean single-VDOM lab and the interface assignments shown. Review any existing configuration before applying. The commands have been prepared for the specified software families but were not executed on your individual EVE-NG installation.

## References
1. Fortinet, *FortiOS 7.6.3 Administration Guide - Policy routes*: https://docs.fortinet.com/document/fortigate/7.6.3/administration-guide/144044/policy-routes
2. Fortinet Community, *Technical Tip: Configuring the Firewall Policy Routes*: https://community.fortinet.com/fortigate-3/technical-tip-configuring-the-firewall-policy-routes-92722
3. Fortinet Community, *Troubleshooting Tip: Policy routing*: https://community.fortinet.com/fortigate-3/troubleshooting-tip-policy-routing-180831
4. Fortinet, *FortiOS 7.6.6 CLI Reference - diagnose ip proute*: https://docs.fortinet.com/document/fortigate/7.6.6/cli-reference/262374995/diagnose-ip-proute
