# Expected verification

## FortiGate
```fortios
get system interface physical
get router info routing-table all
show router policy
diagnose firewall proute list
diagnose ip proute match 192.0.2.10 10.10.10.10 port1 1 0 0 0
```

Expected policy-route entry: ingress `port1`, source `10.10.10.10/32`, destination `192.0.2.10/32`, egress `port3`, gateway `198.51.100.1`.

## Packet capture
Run one capture at a time while generating the indicated ping:
```fortios
diagnose sniffer packet port3 'host 192.0.2.10' 4 0 l
diagnose sniffer packet port2 'host 192.0.2.10' 4 0 l
```
- PC-PBR -> Server-A should appear on port3.
- PC-DEFAULT -> Server-A should appear on port2.
- PC-PBR -> Server-B should appear on port2.
Stop a sniffer with `Ctrl+C`.

## Cisco
```cisco
show ip interface brief
show ip route
show ip route 192.0.2.10
show ip route 203.0.113.2
show ip route 198.51.100.2
```

## VPCS
```text
show
ping 10.10.10.1
ping 192.0.2.10
ping 192.0.2.20
trace 192.0.2.10
```

Exact trace hops can vary by image and TTL behavior. Use FortiGate's egress-interface capture and policy-route diagnostics as the primary evidence.
