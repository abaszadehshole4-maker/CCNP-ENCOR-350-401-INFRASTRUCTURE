# Worked Solutions - FortiGate VRF-Lite

## Solution 1 - Cisco switch

Apply `configs/SW-ACCESS.cfg`. If your IOSvL2 image uses different interface names, map the intended links and update the interface identifiers.

Verify:

```text
show vlan brief
show interfaces trunk
show interfaces status
show mac address-table dynamic
```

Expected: VLANs 10 and 20 exist; Gi0/0 trunks VLANs 10 and 20; Gi0/1 is access VLAN 10; Gi0/2 is access VLAN 20.

## Solution 2 - Cisco ISP router

Apply `configs/R-ISP.cfg`.

Verify:

```text
show ip interface brief
show ip route connected
show ip route 8.8.8.8
show ip route 1.1.1.1
```

Expected: the two /30 networks are connected and both /32 loopbacks are local.

## Solution 3 - FortiGate interfaces and VRFs

Before applying the configuration, enable **System > Feature Visibility > Advanced Routing**. Then apply `configs/FGT-VRF-LAB.conf` from the FortiGate CLI. It contains the interface, route, address-object, policy, and NAT configuration.

Important mapping:

- `port1` is reserved for out-of-band management and is not changed by this lab.
- `port2` -> R-ISP Gi0/0 -> VRF 10
- `port3` -> SW-ACCESS Gi0/0 trunk -> VLAN 10 / VRF 10 and VLAN 20 / VRF 20
- `port4` -> R-ISP Gi0/1 -> VRF 20

Fortinet's 7.6.x VRF example uses `execute router restart` after placing interfaces into VRFs to reconstruct routing tables. Run this separately from the console if required by your build; expect a short routing interruption.

Verify:

```text
get system status
show system interface
get router info routing-table all
get router info routing-table static
```

Expected route-table logic:

- VRF 10: connected `10.10.10.0/24`, connected `203.0.113.0/30`, default via `203.0.113.1`, and blackhole `10.20.20.0/24`.
- VRF 20: connected `10.20.20.0/24`, connected `198.51.100.0/30`, default via `198.51.100.1`, and blackhole `10.10.10.0/24`.

The exact route output formatting varies by FortiOS build.

## Solution 4 - VPCS endpoints

PC-USERS:

```text
ip 10.10.10.10/24 10.10.10.1
save
show
ping 10.10.10.1
ping 8.8.8.8
```

PC-APPS:

```text
ip 10.20.20.10/24 10.20.20.1
save
show
ping 10.20.20.1
ping 1.1.1.1
```

## Solution 5 - Expected test matrix

| Test | Expected | Reason |
|---|---|---|
| USERS -> 10.10.10.1 | Pass | Same-VRF local interface/gateway |
| USERS -> 8.8.8.8 | Pass | VRF 10 default route, policy, and SNAT |
| APPS -> 10.20.20.1 | Pass | Same-VRF local interface/gateway |
| APPS -> 1.1.1.1 | Pass | VRF 20 default route, policy, and SNAT |
| USERS -> 10.20.20.10 | Fail | VRF 10 blackhole route prevents reaching VRF 20 LAN |
| APPS -> 10.10.10.10 | Fail | VRF 20 blackhole route prevents reaching VRF 10 LAN |

## Solution 6 - Prove NAT on the wire

On FortiGate, while generating a ping from PC-USERS:

```text
diagnose sniffer packet any 'host 8.8.8.8' 4 0 l
```

Look for the outgoing packet on `port2` with source `203.0.113.2` and destination `8.8.8.8`.

For PC-APPS:

```text
diagnose sniffer packet any 'host 1.1.1.1' 4 0 l
```

Look for the outgoing packet on `port4` with source `198.51.100.2` and destination `1.1.1.1`.

Stop a capture with `Ctrl+C`.

## Solution 7 - Troubleshooting faults

### Fault A: VLAN 20 missing from trunk

Evidence:

```text
SW-ACCESS# show interfaces trunk
SW-ACCESS# show vlan brief
SW-ACCESS# show mac address-table dynamic vlan 20
```

Correction:

```text
configure terminal
interface GigabitEthernet0/0
 switchport trunk allowed vlan 10,20
end
```

### Fault B: VLAN20-APPS assigned to VRF 10

Evidence:

```text
FGT-VRF-LAB # show system interface
FGT-VRF-LAB # get router info routing-table all
```

Correction:

```text
config system interface
    edit "VLAN20-APPS"
        set vrf 20
    next
end
```

If route tables do not rebuild after changing interface VRF assignment, use the documented routing restart from the console:

```text
execute router restart
```

### Fault C: Wrong VRF 20 next hop

Evidence:

```text
get router info routing-table all
show router static
```

Correction (route ID 20):

```text
config router static
    edit 20
        set gateway 198.51.100.1
        set device "port4"
        set vrf 20
    next
end
```

### Fault D: NAT disabled in policy 20

Evidence:

```text
show firewall policy
```

Correction:

```text
config firewall policy
    edit 20
        set nat enable
    next
end
```

### Fault E: Policy 10 disabled

Evidence:

```text
show firewall policy
```

Correction:

```text
config firewall policy
    edit 10
        set status enable
    next
end
```

If the policy was not disabled but removed, reapply policy 10 from `configs/FGT-VRF-LAB.conf`.

## Solution 8 - Flow-level troubleshooting commands

Use a narrow filter and stop debugging immediately after collecting the required evidence.

```text
diagnose debug reset
diagnose debug flow filter clear
diagnose debug flow filter addr 10.10.10.10
diagnose debug flow show function-name enable
diagnose debug enable
diagnose debug flow trace start 20
```

Generate a single test flow, then stop:

```text
diagnose debug disable
diagnose debug reset
```

Session view:

```text
diagnose sys session filter src 10.10.10.10
diagnose sys session list
diagnose sys session filter clear
```

Configuration/route checks:

```text
show system interface
show router static
show firewall policy
get router info routing-table all
diagnose ip route list
```

## Solution 9 - Why isolation works

A FortiGate VRF is a separate Layer-3 routing/forwarding table. The VLAN 10 interface and WAN port2 are assigned to VRF 10; VLAN 20 and WAN port4 are assigned to VRF 20. The two departments therefore have separate connected routes and separate default routes. The explicit blackhole routes provide a more-specific discard route for the other department's subnet. The firewall policies permit each department to reach only its own simulated ISP path. No route is leaked between VRF 10 and VRF 20.

A firewall policy is not a routing mechanism. If a route does not exist in the relevant VRF, an allow policy cannot make the destination reachable. Route leaking is an advanced, intentional routing design and must be paired with the necessary firewall policies.
