# Verification and troubleshooting

## Layer 2

```text
show vlan brief
show interfaces trunk
show spanning-tree summary
show spanning-tree vlan 10
show spanning-tree vlan 20
show mac address-table dynamic
```

Check that VLANs exist, trunks are up, the allowed/native VLANs match, and STP has selected a loop-free tree. An alternate/blocking port in a redundant triangle is expected.

## HSRP

```text
show standby brief
show standby vlan 10
show standby vlan 20
show standby vlan 30
show standby vlan 40
```

Expected active distribution switch:

- VLANs 10/30: DSW1
- VLANs 20/40: DSW2

If the roles are reversed, inspect HSRP priority, preempt, group number, version, virtual IP, SVI state, VLAN trunking, and tracking state. The two devices must agree on group, virtual IP, and HSRP version.

## OSPF and Layer 3

```text
show ip ospf neighbor
show ip route ospf
show ip route
show ip interface brief
```

Expected OSPF neighbors exist on routed infrastructure links. `ip routing` must be enabled on multilayer switches. Check address/mask and OSPF area on both sides of each link.

## Port security

```text
show port-security
show port-security address
show port-security interface GigabitEthernet0/3
show logging
```

Common problems:

- **Port security command rejected:** image/port does not support it or the port is not in access mode.
- **Trunk stops forwarding:** verify port security was not accidentally applied to an uplink.
- **Host cannot reach network:** check VLAN assignment, trunk allowed VLANs, STP state, IP address and the HSRP VIP gateway.
- **Port security violation:** with `restrict`, unauthorized traffic is dropped but the interface is usually kept up; remove the rogue test host and inspect counters.
- **Sticky MAC remains:** learned sticky MACs may appear in the running configuration. Remove or adjust only after verifying which endpoint is expected.

## Recovery from err-disabled port

This template uses `violation restrict`, not `shutdown`, so a violation should not normally err-disable the port. If you intentionally change the test port to `violation shutdown`, remove the offending endpoint and, after confirming the cause, recover a lab port with:

```text
configure terminal
interface GigabitEthernet0/3
shutdown
no shutdown
end
```

Do not bounce production interfaces without authorization.
