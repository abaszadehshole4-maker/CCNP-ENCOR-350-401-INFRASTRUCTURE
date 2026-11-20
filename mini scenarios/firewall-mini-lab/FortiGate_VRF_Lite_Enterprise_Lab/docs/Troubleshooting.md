# Troubleshooting Runbook

Use a layered workflow. Do not change the firewall policy first when the actual issue may be VLAN tagging, interface state, or routing.

## 1. Confirm the endpoint

VPCS:

```text
show
ping 10.10.10.1
```

or:

```text
show
ping 10.20.20.1
```

Confirm the IP, subnet mask, and default gateway.

## 2. Confirm Cisco switching

```text
show vlan brief
show interfaces trunk
show interfaces status
show mac address-table dynamic
```

Check VLAN IDs, allowed VLANs, port mode, and learned MAC addresses.

## 3. Confirm FortiGate interface/VRF assignment

```text
get system status
show system interface
```

Expected associations:

- port2 and VLAN10-USERS: VRF 10
- port4 and VLAN20-APPS: VRF 20
- VLAN10-USERS and VLAN20-APPS use parent port3 with VLAN IDs 10 and 20
- port1 is preserved for management and is not modified by this lab

## 4. Confirm routing tables

```text
get router info routing-table all
get router info routing-table static
diagnose ip route list
```

Check that each table contains its connected LAN/WAN networks, its own default route, and the expected blackhole route. A default route in VRF 10 must not be assumed to exist in VRF 20, and vice versa.

## 5. Confirm policies and NAT

```text
show firewall policy
show system settings
```

Ensure policy 10 matches VLAN10-USERS -> port2 and policy 20 matches VLAN20-APPS -> port4. Confirm NAT is enabled in each policy and understand whether the system uses policy NAT or central NAT.

## 6. Capture packets

```text
diagnose sniffer packet any 'host 8.8.8.8' 4 0 l
```

For the second test path:

```text
diagnose sniffer packet any 'host 1.1.1.1' 4 0 l
```

Use Ctrl+C to stop the capture. Verify which interface sees the packet and whether the source address is translated to the WAN interface address.

## 7. Inspect a session

```text
diagnose sys session filter src 10.10.10.10
diagnose sys session list
diagnose sys session filter clear
```

## 8. Use debug flow carefully

```text
diagnose debug reset
diagnose debug flow filter clear
diagnose debug flow filter addr 10.10.10.10
diagnose debug flow show function-name enable
diagnose debug enable
diagnose debug flow trace start 20
```

Generate one test flow, then stop immediately:

```text
diagnose debug disable
diagnose debug reset
```

Do not leave debug enabled on a busy or production firewall. Use the narrowest possible filter and minimum trace count.

## Fault isolation guide

| Symptom | First area to check | Useful evidence |
|---|---|---|
| PC cannot ping its gateway | Access VLAN, trunk allowed list, FortiGate VLAN interface | `show vlan brief`, `show interfaces trunk`, `show system interface` |
| Gateway works but Internet target fails | VRF default route, policy, NAT, upstream link | routing table, `show firewall policy`, sniffer |
| Only one department fails | That department's VRF/interface/route/policy | VRF-specific section in routing table |
| Cross-department ping fails | Expected behavior in this lab | blackhole route in the source VRF |
| Packet exits but no reply returns | NAT/return path/upstream | sniffer on WAN, ISP route table |
| Policy appears not to match | Source/destination/service/interface and route | traffic logs, debug flow |
