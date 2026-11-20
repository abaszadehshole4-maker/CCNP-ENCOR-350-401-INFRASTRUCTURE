# Lab Tasks - FortiGate VRF-Lite

Complete the tasks in order. Try each task before opening `SOLUTIONS.md`.

## Task 1 - Build and cable the topology

Add these EVE-NG nodes:

- FortiGate VM running FortiOS 7.6.7 (target release)
- Cisco IOSv router `R-ISP`
- Cisco IOSvL2 switch `SW-ACCESS`
- VPCS `PC-USERS`
- VPCS `PC-APPS`

Cable according to the README and topology diagram. Preserve FortiGate `port1` for its existing management network. The lab data interfaces are `port2`, `port3`, and `port4`.

**Verify:** all expected device consoles open and the links match the port map.

## Task 2 - Configure VLANs and switch ports

On `SW-ACCESS`:

1. Create VLAN 10 named `USERS`.
2. Create VLAN 20 named `APPS`.
3. Configure Gi0/0 as an 802.1Q trunk that carries only VLANs 10 and 20. This link connects to FortiGate port3.
4. Configure Gi0/1 as an access port in VLAN 10 for PC-USERS.
5. Configure Gi0/2 as an access port in VLAN 20 for PC-APPS.

**Verify:** `show vlan brief`, `show interfaces trunk`, and `show interfaces status`.

## Task 3 - Configure the ISP simulator

On `R-ISP`:

1. Configure Gi0/0 as `203.0.113.1/30`. It connects to FortiGate port2 (USERS / VRF 10).
2. Configure Gi0/1 as `198.51.100.1/30`. It connects to FortiGate port4 (APPS / VRF 20).
3. Configure Loopback0 as `8.8.8.8/32` (USERS test target).
4. Configure Loopback1 as `1.1.1.1/32` (APPS test target).

**Verify:** `show ip interface brief`, `show ip route connected`, and `show ip route 8.8.8.8` / `show ip route 1.1.1.1`.

## Task 4 - Configure endpoint addressing

On PC-USERS:

- Address: `10.10.10.10/24`
- Default gateway: `10.10.10.1`

On PC-APPS:

- Address: `10.20.20.10/24`
- Default gateway: `10.20.20.1`

**Verify:** each PC can ping its own gateway after the FortiGate VLAN interfaces are configured.

## Task 5 - Enable and configure FortiGate VRFs

1. In the FortiGate GUI, enable **System > Feature Visibility > Advanced Routing** if it is hidden.
2. Assign FortiGate port2 (WAN-USERS) to VRF 10.
3. Configure port3 as the 802.1Q parent/trunk interface.
4. Create VLAN interface `VLAN10-USERS` on port3, VLAN ID 10, and assign it to VRF 10.
5. Assign FortiGate port4 (WAN-APPS) to VRF 20.
6. Create VLAN interface `VLAN20-APPS` on port3, VLAN ID 20, and assign it to VRF 20.
7. Preserve port1; do not change its management configuration.

**Verify:** `show system interface` and confirm the intended parent, VLAN ID, addressing and `set vrf` values.

## Task 6 - Configure routing separation

1. Add a default route in VRF 10 through `203.0.113.1` using port2.
2. Add a default route in VRF 20 through `198.51.100.1` using port4.
3. Add a blackhole route for `10.20.20.0/24` inside VRF 10.
4. Add a blackhole route for `10.10.10.0/24` inside VRF 20.

**Verify:** `show router static` and `get router info routing-table all`. Confirm each VRF has its own connected routes, default route and blackhole route.

## Task 7 - Configure firewall policies and source NAT

1. Create address objects for USERS (`10.10.10.0/24`) and APPS (`10.20.20.0/24`).
2. Create a policy from `VLAN10-USERS` to `port2`, source `NET-USERS-VRF10`, destination `all`, and enable policy NAT plus logging.
3. Create a policy from `VLAN20-APPS` to `port4`, source `NET-APPS-VRF20`, destination `all`, and enable policy NAT plus logging.
4. Keep the broad `ALL` service setting limited to this isolated training lab. A production policy should allow only documented application services.
5. Confirm central NAT is not enabled if using the policy NAT configuration supplied in this repository.

**Verify:** `show firewall policy`, `show system settings`, and successful tests to the corresponding loopback targets.

## Task 8 - Prove both VRFs work independently

From PC-USERS:

- `ping 10.10.10.1` - expected success.
- `ping 8.8.8.8` - expected success.
- `ping 10.20.20.10` - expected failure.

From PC-APPS:

- `ping 10.20.20.1` - expected success.
- `ping 1.1.1.1` - expected success.
- `ping 10.10.10.10` - expected failure.

**Explain:** why each expected failure is a routing-isolation result caused by the source VRF's blackhole route, not simply a missing inter-VLAN allow policy.

## Task 9 - Verify the translated source addresses

1. Capture traffic on FortiGate while PC-USERS pings `8.8.8.8`.
2. Confirm the packet exits `port2` and its source is translated to `203.0.113.2`.
3. Repeat for PC-APPS to `1.1.1.1`; confirm egress `port4` and source `198.51.100.2`.

Use `diagnose sniffer packet` and firewall traffic logs. Stop the capture with Ctrl+C.

## Task 10 - Failure-injection troubleshooting

Inject one fault at a time and document symptom, evidence, root cause, correction and retest:

A. Remove VLAN 20 from the trunk allowed list on SW-ACCESS Gi0/0.

B. Change the `VLAN20-APPS` interface VRF from 20 to 10.

C. Change the VRF 20 default-route gateway to an incorrect address (the correct gateway is `198.51.100.1` through `port4`).

D. Disable NAT in firewall policy 20.

E. Disable firewall policy 10.

**Deliverable:** a five-row incident report with the command or log that proves each fault.

## Task 11 - Explain operational limits

Answer these questions in your own words:

1. How is a VLAN different from a VRF?
2. How is a VRF different from a VDOM?
3. Why does a firewall policy not create a route between VRF 10 and VRF 20?
4. What is route leaking, and why should it be explicitly controlled?
5. Why does this lab use separate WAN interfaces for the two routing domains?
