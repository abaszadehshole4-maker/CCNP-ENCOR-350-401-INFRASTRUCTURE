# Troubleshooting Guide

## BGP neighbor Idle or Active

First verify the VRF-specific path:

```text
ping vrf BLUE 172.31.100.2
ping vrf GREEN 172.31.200.2
```

Then check:

```text
show bgp vpnv4 vrf BLUE summary
show bgp vpnv4 vrf GREEN summary
```

## Remote AS mismatch

Compare the PE and CE configuration:

```text
show running-config | section router bgp
```

BLUE must use CE-A AS 65101; GREEN must use CE-B AS 65102.

## Neighbor configured in the wrong address family

On PE-SW the neighbor must live under:

```text
address-family ipv4 vrf BLUE
```

or:

```text
address-family ipv4 vrf GREEN
```

## BGP Established but no route learned

On the CE, verify the route exists exactly as required by the `network` statement:

```text
show ip route 192.0.2.10
show ip route 192.168.10.0
```

Do the same for CE-B.

## Wrong VRF

Compare:

```text
show ip route vrf BLUE
show ip route vrf GREEN
```

A customer route appearing in the other VRF indicates a configuration problem.

## PE interface lost its IP address

On IOS/IOS XE, applying `ip vrf forwarding` can remove the existing IPv4 address. Reapply it:

```text
ip address 172.31.100.1 255.255.255.252
```

Use the correct address for the interface being repaired.

## Systematic checklist

```text
Interface up/up
→ VRF assignment correct
→ PE can reach CE in correct VRF
→ eBGP Established
→ CE advertises prefix
→ PE learns prefix in correct VRF
→ End host works
```
