# Verification and troubleshooting

## 1. Check VLANs

```text
show vlan brief
```

Expected:

- VLAN 2 exists.
- VLAN 4 exists.
- Fa0/3 is in VLAN 2.
- Fa0/4 is in VLAN 4.

## 2. Check SVIs

```text
show ip interface brief
```

Look for:

```text
Vlan2       192.168.102.129    up    up
Vlan4       192.168.103.171    up    up
Port-channel1 192.168.101.10   up    up
```

If an SVI is down/down, make sure the VLAN exists and at least one access port in that VLAN is active.

## 3. Check EtherChannel

```text
show etherchannel summary
```

You want Port-channel 1 to be operational and Fa0/1 and Fa0/2 to be members.

Also check:

```text
show interfaces port-channel 1
```

## 4. Check the individual links

```text
show interfaces FastEthernet0/1
show interfaces FastEthernet0/2
```

Both should be operational.

## 5. Test the routed link

From SwitchA:

```text
ping 192.168.101.9
```

From SwitchB:

```text
ping 192.168.101.10
```

If these fail, troubleshoot EtherChannel before troubleshooting OSPF.

## 6. Check OSPF configuration

```text
show running-config | section router ospf
```

Expected:

```text
router ospf 10
 network 192.168.101.8 0.0.0.3 area 0
 network 192.168.102.128 0.0.0.31 area 102
 network 192.168.103.160 0.0.0.15 area 103
```

## 7. Check OSPF neighbor

```text
show ip ospf neighbor
```

The other switch should appear as a neighbor in FULL state.

## 8. Check OSPF interfaces

```text
show ip ospf interface brief
```

This confirms which interfaces participate in OSPF and their areas.

## 9. Check OSPF routes

```text
show ip route ospf
```

You should see OSPF-learned routes for the remote VLAN subnets.

## 10. Test SwitchA routing

From SwitchA:

```text
ping 192.168.102.130
ping 192.168.103.172
```

## 11. Test PCs

PC1:

```text
ping 192.168.102.129
ping 192.168.102.130
ping 192.168.103.171
ping 192.168.103.172
```

PC2:

```text
ping 192.168.103.171
ping 192.168.103.172
ping 192.168.102.129
ping 192.168.102.130
```

Then test PC-to-PC connectivity.

## Troubleshooting checklist

### EtherChannel does not form

Check both switches:

```text
show etherchannel summary
show interfaces status
show running-config interface FastEthernet0/1
show running-config interface FastEthernet0/2
```

Both sides must use compatible settings.

For this lab both sides use:

```text
channel-group 1 mode on
```

### OSPF neighbor is missing

Check:

```text
ping 192.168.101.9
show ip ospf neighbor
show ip ospf interface Port-channel1
```

Make sure both Port-channel interfaces are in area 0.

### SVI is down

Check:

```text
show vlan brief
show interfaces vlan 2
show interfaces vlan 4
```

Make sure the VLAN exists and an active port belongs to the VLAN.

### PC cannot ping its gateway

Check:

1. PC IP address.
2. Subnet mask.
3. Default gateway.
4. Switch access VLAN.
5. SVI status.

### OSPF routes are missing

Check:

```text
show ip ospf neighbor
show ip route ospf
show ip ospf interface brief
```

Then verify the three network statements.
