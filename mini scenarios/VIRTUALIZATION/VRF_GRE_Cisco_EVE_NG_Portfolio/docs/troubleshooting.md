# Troubleshooting Guide

## Decision Tree

```text
PC-to-PC fails
     |
     v
Check local interfaces
     |
     v
Check underlay ping
     |
     v
Check VRF exists
     |
     v
Check Tunnel0 up/up
     |
     v
Check VRF tunnel ping
     |
     v
Check remote VRF route
     |
     v
Check ARP
     |
     v
Retest end-to-end
```

## Commands

```cisco
show ip interface brief
show vrf
show ip route
show ip route vrf CUSTOMER
show ip interface Tunnel0
show interfaces Tunnel0
show run interface Tunnel0
show ip arp vrf CUSTOMER
ping 10.0.12.2
ping vrf CUSTOMER 172.16.12.2
ping vrf CUSTOMER 192.168.20.10
traceroute vrf CUSTOMER 192.168.20.10
```

## Common Faults

### Wrong underlay address
Fix the Gi0/1 addresses and /30 mask.

### Wrong GRE destination
R1 must use 10.0.12.2; R2 must use 10.0.12.1.

### Tunnel not in CUSTOMER
Verify:

```cisco
show ip interface Tunnel0
```

### Missing remote route
R1:

```cisco
ip route vrf CUSTOMER 192.168.20.0 255.255.255.0 172.16.12.2
```

R2:

```cisco
ip route vrf CUSTOMER 192.168.10.0 255.255.255.0 172.16.12.1
```

### Debugging

```cisco
debug tunnel
```

Stop debugging immediately after testing:

```cisco
undebug all
```
