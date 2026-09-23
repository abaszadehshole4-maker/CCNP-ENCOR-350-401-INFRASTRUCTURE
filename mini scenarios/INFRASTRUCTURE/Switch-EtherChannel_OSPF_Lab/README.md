# Layer 3 EtherChannel + Multi-Area OSPF Lab

**Author:** Sholeh  
**Platform:** Cisco IOS multilayer switches / EVE-NG or Packet Tracer (with appropriate interface naming)

## 1. Objective

Configure two Layer 3 switches connected by a routed EtherChannel and run OSPF process 10 using three areas:

- EtherChannel transit link: **OSPF area 0**
- VLAN 2: **OSPF area 102**
- VLAN 4: **OSPF area 103**

The main task requirements are implemented on **SwitchA**.

## 2. Topology

```text
                    Routed EtherChannel
             Fa0/1 ======= Po1 ======= Fa0/1
             Fa0/2 ======= Po1 ======= Fa0/2
              SwitchA                  SwitchB
           Po1 .10/30                Po1 .9/30
            /       \              //       \
       VLAN 2       VLAN 4      VLAN 2       VLAN 4
      .129/27      .171/28     .130/27      .172/28
        |             |           |             |
       PC1           PC2         PC3           PC4
```

## 3. Addressing

| Device | Interface | Address | Mask | OSPF Area |
|---|---|---|---|---|
| SwitchA | Port-channel1 | 192.168.101.10 | /30 | 0 |
| SwitchB | Port-channel1 | 192.168.101.9 | /30 | 0 |
| SwitchA | VLAN 2 | 192.168.102.129 | /27 | 102 |
| SwitchB | VLAN 2 | 192.168.102.130 | /27 | 102 |
| SwitchA | VLAN 4 | 192.168.103.171 | /28 | 103 |
| SwitchB | VLAN 4 | 192.168.103.172 | /28 | 103 |
| PC1 | VLAN 2 | 192.168.102.131 | /27 | GW .129 |
| PC2 | VLAN 4 | 192.168.103.173 | /28 | GW .171 |
| PC3 | VLAN 2 | 192.168.102.132 | /27 | GW .130 |
| PC4 | VLAN 4 | 192.168.103.174 | /28 | GW .172 |

> The PC addresses are example addresses chosen so the four-host scenario can be tested without using the switch addresses.

## 4. Important concept: `mode on`

The requirement says the two physical ports must **not use an EtherChannel negotiation protocol**.

Therefore:

```text
channel-group 1 mode on
```

is used.

`mode on` creates a static EtherChannel. It does not use LACP or PAgP.

## 5. Important concept: Layer 3 EtherChannel

Because Port-channel1 must have an IP address, this is a **routed EtherChannel**.

The physical members are changed to Layer 3 ports with:

```text
no switchport
```

The logical Port-channel also uses:

```text
no switchport
```

Then the IP address is placed on Port-channel1, not on Fa0/1 or Fa0/2.

## 6. OSPF subnet calculations

### EtherChannel /30

192.168.101.10/30 belongs to:

- Network: 192.168.101.8
- Usable: 192.168.101.9–192.168.101.10
- Broadcast: 192.168.101.11
- Wildcard: 0.0.0.3
- Area: 0

OSPF:

```text
network 192.168.101.8 0.0.0.3 area 0
```

### VLAN 2 /27

192.168.102.129/27 belongs to:

- Network: 192.168.102.128
- Usable: 192.168.102.129–192.168.102.158
- Broadcast: 192.168.102.159
- Wildcard: 0.0.0.31
- Area: 102

OSPF:

```text
network 192.168.102.128 0.0.0.31 area 102
```

### VLAN 4 /28

192.168.103.171/28 belongs to:

- Network: 192.168.103.160
- Usable: 192.168.103.161–192.168.103.174
- Broadcast: 192.168.103.175
- Wildcard: 0.0.0.15
- Area: 103

OSPF:

```text
network 192.168.103.160 0.0.0.15 area 103
```

## 7. Testing order

Do not start with OSPF. Test from the bottom up:

1. VLANs exist.
2. SVI interfaces are up/up.
3. Port-channel is formed.
4. SwitchA can ping SwitchB's Port-channel address.
5. OSPF neighbor reaches FULL.
6. OSPF routes appear.
7. PCs can ping their local gateway.
8. PCs can ping remote VLANs.
9. End-to-end PC-to-PC ping works.

## 8. Expected OSPF result

On both switches:

```text
show ip ospf neighbor
```

You should see the other switch as an OSPF neighbor over the Port-channel.

The exact neighbor state should become:

```text
FULL
```

## 9. Common mistakes

### Mistake 1: Using LACP

Do not use:

```text
channel-group 1 mode active
channel-group 1 mode passive
```

Those are LACP modes.

### Mistake 2: Using PAgP

Do not use:

```text
channel-group 1 mode desirable
channel-group 1 mode auto
```

Those are PAgP modes.

### Mistake 3: Putting the IP on Fa0/1

Do not configure the 192.168.101.x address on the physical member ports.

Put it on:

```text
interface Port-channel1
```

### Mistake 4: Forgetting `ip routing`

Without:

```text
ip routing
```

the multilayer switch will not perform Layer 3 routing.

### Mistake 5: Wrong OSPF network address

The OSPF statement uses the **subnet address**, not necessarily the interface IP address.

For example, 192.168.102.129/27 belongs to subnet 192.168.102.128/27.

## 10. Save configuration

After testing:

```text
copy running-config startup-config
```

or:

```text
write memory
```
