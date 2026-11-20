# GitHub / LinkedIn Publishing Checklist

Before publishing:

- [ ] Replace the author field in the Word guide if desired.
- [ ] Confirm that no passwords, API keys, license files, serial numbers, or private IP details from a real environment are included.
- [ ] Make sure the EVE-NG topology screenshot reflects the actual lab if you choose to add one.
- [ ] Test the configuration on your own FortiOS 7.6.7 VM and note any platform-specific interface-name adjustments.
- [ ] Record the actual test outputs or screenshots; do not claim that a lab was tested unless you have performed it.
- [ ] Use the GitHub README as the project landing page.
- [ ] Include a short explanation of the learning objectives and the expected test matrix in your LinkedIn post.

Suggested LinkedIn text:

> I built a small multi-VRF enterprise lab with FortiGate 7.6.x, Cisco IOSv, Cisco IOSvL2, and EVE-NG. The lab separates USERS and APPS into VRF 10 and VRF 20, uses independent WAN paths and source NAT, and verifies both connectivity and cross-VRF isolation. The repository includes the topology, node configurations, step-by-step tasks, worked solutions, and troubleshooting commands.
>
> Key learning points: VRF vs VLAN vs VDOM, interface-to-VRF assignment, per-VRF static routing, blackhole routes, firewall policies, source NAT, and evidence-based troubleshooting.
>
> Note: This is a lab simulation using documentation IP ranges and test loopbacks, not a production design.
