# Worked Solutions - FortiGate Policy-Based Routing

## 1-3. Build and verify the underlay
Use the complete configurations in `configs/`. Verify interface status and direct neighbors before configuring PBR:

FortiGate:
```fortios
get system interface physical
execute ping 203.0.113.1
execute ping 198.51.100.1
```

Cisco:
```cisco
show ip interface brief
show ip route
ping 10.0.1.2
ping 10.0.2.2
```

## 4. Ordinary routing
The baseline FortiGate default route points to ISP-A:
```fortios
config router static
    edit 1
        set dst 0.0.0.0 0.0.0.0
        set gateway 203.0.113.1
        set device "port2"
        set distance 10
    next
end
```

## 5. Policy route
```fortios
config router policy
    edit 10
        set input-device "port1"
        set src "10.10.10.10/255.255.255.255"
        set dst "192.0.2.10/255.255.255.255"
        set action permit
        set gateway 198.51.100.1
        set output-device "port3"
        set status enable
        set comments "PC-PBR to Server-A via ISP-B"
    next
end
```
The source and destination masks are /32 (one host each). The incoming interface is the FortiGate LAN port. The policy route forwards a match to the ISP-B next hop and port3.

## 6. Firewall policy and NAT
The full FortiGate file creates a narrowly scoped WAN2 policy for PC-PBR -> Server-A and a WAN1 policy for other traffic. NAT is enabled in each. For a production environment, do not use `service ALL`; restrict services and destinations to business requirements.

## 7-9. Expected paths
| Test | Expected egress | Reason |
|---|---|---|
| PC-PBR -> 192.0.2.10 | port3 / WAN2 | Source and destination both match PBR |
| PC-DEFAULT -> 192.0.2.10 | port2 / WAN1 | Source does not match PBR; default route applies |
| PC-PBR -> 192.0.2.20 | port2 / WAN1 | Destination does not match PBR; default route applies |

Use:
```fortios
diagnose firewall proute list
diagnose ip proute match 192.0.2.10 10.10.10.10 port1 1 0 0 0
get router info routing-table all
diagnose sys session filter src 10.10.10.10
diagnose sys session list
diagnose sys session filter clear
```
A session can retain its established path. When changing rules during a test, use a new flow or deliberately clear only the relevant lab session.

## 10. Expand source scope
Change the source match from `10.10.10.10/255.255.255.255` to `10.10.10.0/255.255.255.0`. Both PCs then match for Server-A and use WAN2. Restore the /32 host match to return to the original requirement.

## 11. Add a protocol condition
Example: match ICMP only (IP protocol number 1) from PC-DEFAULT to Server-A and send it via WAN2:
```fortios
config router policy
    edit 20
        set input-device "port1"
        set src "10.10.10.20/255.255.255.255"
        set dst "192.0.2.10/255.255.255.255"
        set protocol 1
        set action permit
        set gateway 198.51.100.1
        set output-device "port3"
        set status enable
    next
end
```
This second rule is more specific than a broader rule. If rules overlap, ensure the intended match is evaluated first. Remove it after the test:
```fortios
config router policy
    delete 20
end
```

## 12. Troubleshoot a failed next hop
A policy route requires a usable active route to its gateway or destination. Check:
```fortios
get router info routing-table all
diagnose firewall proute list
execute ping 198.51.100.1
```
Restore the correct gateway `198.51.100.1`, `output-device "port3"`, and link state. Also check that the firewall policy allows the port1-to-port3 flow and that the Core has a return route to the translated WAN2 IP.
