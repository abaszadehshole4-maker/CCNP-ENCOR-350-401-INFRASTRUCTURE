# Lab Guide — VRF-Lite Multi-CE eBGP

## Step 1 — Verify local customer LANs

On CE-A and CE-B:

```text
show ip interface brief
show ip route
```

Make sure the LAN interfaces and loopbacks are up.

## Step 2 — Build the VRFs on PE-SW

```text
configure terminal
ip vrf BLUE
 rd 65000:101
exit
ip vrf GREEN
 rd 65000:102
exit
```

Verify:

```text
show ip vrf
```

## Step 3 — Place the PE-CE ports into the correct VRF

BLUE:

```text
interface GigabitEthernet1/0/1
 no switchport
 ip vrf forwarding BLUE
 ip address 172.31.100.1 255.255.255.252
 no shutdown
```

GREEN:

```text
interface GigabitEthernet1/0/2
 no switchport
 ip vrf forwarding GREEN
 ip address 172.31.200.1 255.255.255.252
 no shutdown
```

Then verify the VRF routing tables.

## Step 4 — Configure eBGP for BLUE

PE-SW:

```text
router bgp 65000
 bgp router-id 10.255.100.1
 address-family ipv4 vrf BLUE
  neighbor 172.31.100.2 remote-as 65101
  neighbor 172.31.100.2 activate
 exit-address-family
```

CE-A:

```text
router bgp 65101
 bgp router-id 192.0.2.10
 neighbor 172.31.100.1 remote-as 65000
 network 192.0.2.10 mask 255.255.255.255
 network 192.168.10.0 mask 255.255.255.0
```

Verify:

```text
PE-SW# show bgp vpnv4 vrf BLUE summary
CE-A# show ip bgp summary
PE-SW# show ip route vrf BLUE
```

## Step 5 — Configure eBGP for GREEN

PE-SW:

```text
router bgp 65000
 address-family ipv4 vrf GREEN
  neighbor 172.31.200.2 remote-as 65102
  neighbor 172.31.200.2 activate
 exit-address-family
```

CE-B:

```text
router bgp 65102
 bgp router-id 192.0.2.20
 neighbor 172.31.200.1 remote-as 65000
 network 192.0.2.20 mask 255.255.255.255
 network 192.168.20.0 mask 255.255.255.0
```

Verify:

```text
PE-SW# show bgp vpnv4 vrf GREEN summary
CE-B# show ip bgp summary
PE-SW# show ip route vrf GREEN
```

## Step 6 — Demonstrate VRF isolation

On PE-SW:

```text
show ip route vrf BLUE
show ip route vrf GREEN
```

BLUE should contain Alpha routes; GREEN should contain Beta routes.

## Step 7 — Controlled failure test

Shut the BLUE PE-CE link:

```text
interface GigabitEthernet1/0/1
 shutdown
```

Observe:

```text
show bgp vpnv4 vrf BLUE summary
show ip route vrf BLUE
show logging
```

Restore it:

```text
interface GigabitEthernet1/0/1
 no shutdown
```

Confirm the neighbor returns to Established and the Alpha routes are relearned.

## Step 8 — Final portfolio evidence

Capture screenshots of:

```text
show ip vrf
show bgp vpnv4 vrf BLUE summary
show bgp vpnv4 vrf GREEN summary
show ip route vrf BLUE
show ip route vrf GREEN
show ip bgp
```
