# Worked Solutions - Dynamic Routing Lab

This file contains the expected solution configuration and exact troubleshooting corrections. Full device configurations are in `configs/`.

## Solution 1 - Configure the switch
Apply `configs/Cisco-SW1/SW-LAN.txt`. Verify:

```text
show vlan brief
show interfaces trunk
show interfaces status
```

VLAN 10 and 20 must exist. Gi0/1 must be trunking and allow VLANs 10,20. Fa0/2 must be access VLAN 10; Fa0/3 access VLAN 20.

## Solution 2 - Configure CORE-R1 and VPCS
Apply `configs/Cisco-Core-R1/CORE-R1.txt` and the two VPCS files. Verify:

```text
show ip interface brief
show ip route connected
show ip ospf interface brief
```

From PC-USER ping `10.10.10.1`; from PC-SERVER ping `10.10.20.1`.

## Solution 3 - OSPF adjacency and routes
The core config uses:

```text
router ospf 10
 router-id 10.255.0.2
 passive-interface default
 no passive-interface GigabitEthernet0/0
 network 10.255.0.0 0.0.0.3 area 0
 network 10.10.10.0 0.0.0.255 area 0
 network 10.10.20.0 0.0.0.255 area 0
```

The FortiGate config uses `config router ospf`, router ID `10.255.0.1`, Area `0.0.0.0`, and network `10.255.0.0/30` on `port3`. Verify:

```text
# FortiGate
get router info ospf neighbor
get router info ospf interface
get router info routing-table ospf

# Cisco CORE-R1
show ip ospf neighbor
show ip route ospf
```

A FULL neighbor relationship is expected. FortiGate should learn `10.10.10.0/24` and `10.10.20.0/24` through `10.255.0.2` on port3.

## Solution 4 - BGP peering and route exchange
ISP-R2:

```text
router bgp 65000
 bgp router-id 198.51.100.1
 neighbor 198.51.100.2 remote-as 65010
 neighbor 198.51.100.2 description FORTIGATE-EDGE-AS65010
 neighbor 198.51.100.2 soft-reconfiguration inbound
 neighbor 198.51.100.2 default-originate
 network 203.0.113.1 mask 255.255.255.255
```

FortiGate:

```text
config router bgp
    set as 65010
    set router-id 198.51.100.2
    config neighbor
        edit "198.51.100.1"
            set remote-as 65000
            set soft-reconfiguration enable
        next
    end
    config network
        edit 1
            set prefix 10.10.10.0 255.255.255.0
        next
        edit 2
            set prefix 10.10.20.0 255.255.255.0
        next
    end
end
```

Verify:

```text
# FortiGate
get router info bgp summary
get router info bgp neighbors 198.51.100.1 advertised-routes
get router info routing-table bgp

# ISP-R2
show ip bgp summary
show ip bgp
show ip route bgp
show ip bgp neighbors 198.51.100.2 received-routes
```

FortiGate should receive `0.0.0.0/0` and `203.0.113.1/32`. ISP should learn the two LAN /24s.

## Solution 5 - Originate ISP default into OSPF
First verify FortiGate has a BGP default route:

```text
get router info routing-table bgp
get router info routing-table all
```

Then FortiGate OSPF contains:

```text
config router ospf
    set default-information-originate enable
end
```

This option advertises a default when FortiGate has a qualifying default route. It is intentionally `enable`, not `always`, so the lab default is withdrawn if the BGP-learned default disappears. Verify on CORE-R1:

```text
show ip route 0.0.0.0
show ip route ospf
```

Expected route type is usually `O*E2` (format may vary slightly by IOS image).

## Solution 6 - End-to-end traffic
On FortiGate, ensure the lab policy exists from port3 to port2, matching source objects LAN10-USERS and LAN20-SERVERS and destination ISP-TEST-LO0, with NAT disabled. Verify policy and routing:

```text
show firewall policy
get router info routing-table all
```

From each VPCS:

```text
ping 203.0.113.1
```

No NAT is used. ISP-R2 knows how to return to both private LANs because it learned the routes over BGP.

## Solution 7 - Optional inbound prefix filtering
On ISP-R2:

```text
configure terminal
ip prefix-list FGT-LAN-IN seq 5 permit 10.10.10.0/24
router bgp 65000
 neighbor 198.51.100.2 prefix-list FGT-LAN-IN in
end
clear ip bgp 198.51.100.2 soft in
```

Now ISP should learn only VLAN 10. Remove the filter:

```text
configure terminal
router bgp 65000
 no neighbor 198.51.100.2 prefix-list FGT-LAN-IN in
exit
no ip prefix-list FGT-LAN-IN
end
clear ip bgp 198.51.100.2 soft in
```

Verify that both LAN routes return.

## Solution 8 - OSPF failure and recovery
On CORE-R1:

```text
configure terminal
interface GigabitEthernet0/0
 shutdown
end
```

Verify on FortiGate:

```text
get router info ospf neighbor
get router info routing-table ospf
get router info bgp neighbors 198.51.100.1 advertised-routes
```

Restore:

```text
configure terminal
interface GigabitEthernet0/0
 no shutdown
end
```

Wait for the OSPF adjacency to return to FULL. Confirm LAN routes reappear on FortiGate and then in ISP BGP.

## Solution 9 - BGP failure and recovery
On ISP-R2:

```text
configure terminal
router bgp 65000
 neighbor 198.51.100.2 shutdown
end
```

Verify BGP is down, the BGP default is removed from FortiGate, and CORE-R1 no longer has the OSPF external default (after convergence).

Restore:

```text
configure terminal
router bgp 65000
 no neighbor 198.51.100.2 shutdown
end
```

Verify BGP Established, default received, and OSPF default re-originated.

## Solution 10 - Common fault corrections

### A. BGP stays Idle or Active
Check link/IP reachability, then both AS numbers and neighbor IP addresses:

```text
# FortiGate
get router info bgp summary
execute ping 198.51.100.1
show router bgp

# ISP-R2
show ip bgp summary
show ip interface brief
show running-config | section router bgp
```

Correct FortiGate remote AS to `65000` and ISP remote AS to `65010`. Ensure both peer IPs are `198.51.100.1` / `.2` and the /30 link is up.

### B. OSPF neighbor does not reach FULL
Check the transit IP/subnet, Area 0, interface state, network type, hello/dead intervals and passive-interface setting:

```text
# FortiGate
get router info ospf neighbor
get router info ospf interface
show router ospf

# CORE-R1
show ip ospf neighbor
show ip ospf interface GigabitEthernet0/0
show running-config | section router ospf
```

Make both sides Area 0; both network types point-to-point; use hello 10 and dead 40 (or return both sides to matching defaults). Ensure CORE-R1 Gi0/0 is not passive.

### C. LAN route not advertised to ISP
A FortiGate BGP `network` statement needs a matching route in the FortiGate routing table. Check OSPF first:

```text
get router info routing-table ospf
get router info bgp neighbors 198.51.100.1 advertised-routes
```

Restore OSPF adjacency or correct the exact prefix/mask in `config router bgp -> config network`.

### D. BGP up but clients cannot ping external test loopback
Check in this order: PC address/gateway -> switch VLAN/access/trunk -> R1 connected routes -> R1 default OSPF route -> FortiGate BGP /32 route -> FortiGate policy/log -> ISP BGP return route. Do not change NAT unless you also redesign the return path.

### E. FortiGate default not present in OSPF
Check that the BGP default is installed first. `default-information-originate enable` will not advertise if FortiGate has no qualifying default. Verify:

```text
get router info routing-table bgp
get router info routing-table all
get router info ospf neighbor
```

Correct the ISP `neighbor ... default-originate` command and restore BGP before changing the OSPF configuration.

## Expected final route view

| Device | Expected learned routes |
|---|---|
| FortiGate | OSPF: 10.10.10.0/24, 10.10.20.0/24; BGP: 0.0.0.0/0, 203.0.113.1/32 |
| CORE-R1 | OSPF external default 0.0.0.0/0 via 10.255.0.1 |
| ISP-R2 | BGP: 10.10.10.0/24 and 10.10.20.0/24 via 198.51.100.2 |

Remember: exact route codes and formatting vary by vendor and software release. Focus on protocol source, prefix, next hop and interface.
