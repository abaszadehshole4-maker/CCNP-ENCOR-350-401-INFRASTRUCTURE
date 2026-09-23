# Command-by-command explanation

## SwitchA

### Enter configuration mode

```text
enable
configure terminal
```

- `enable` enters privileged EXEC mode.
- `configure terminal` enters global configuration mode.

### Enable Layer 3 routing

```text
ip routing
```

This changes the multilayer switch from simple Layer 2 switching only into a device capable of routing between VLANs and routed interfaces.

### Create VLANs

```text
vlan 2
 name VLAN2
vlan 4
 name VLAN4
```

These commands create the two VLANs used by the PCs.

### Prepare EtherChannel member ports

```text
interface range FastEthernet0/1 - 2
 no switchport
 channel-group 1 mode on
 no shutdown
```

- `interface range` selects both physical links.
- `no switchport` makes them Layer 3 routed ports.
- `channel-group 1 mode on` places both links into Port-channel 1 without LACP/PAgP.
- `no shutdown` enables the ports.

### Configure the Port-channel

```text
interface Port-channel1
 no switchport
 ip address 192.168.101.10 255.255.255.252
 no shutdown
```

The Port-channel becomes the logical Layer 3 interface. Its /30 address is used for the OSPF area 0 transit link.

### Configure VLAN 2 SVI

```text
interface Vlan2
 ip address 192.168.102.129 255.255.255.224
 no shutdown
```

The SVI is the default gateway for devices in VLAN 2.

### Configure VLAN 4 SVI

```text
interface Vlan4
 ip address 192.168.103.171 255.255.255.240
 no shutdown
```

The SVI is the default gateway for devices in VLAN 4.

### Put PC ports into their VLANs

```text
interface FastEthernet0/3
 switchport mode access
 switchport access vlan 2
 spanning-tree portfast
 no shutdown
```

Fa0/3 is an access port for VLAN 2.

```text
interface FastEthernet0/4
 switchport mode access
 switchport access vlan 4
 spanning-tree portfast
 no shutdown
```

Fa0/4 is an access port for VLAN 4.

### Configure OSPF

```text
router ospf 10
```

Creates OSPF process 10.

Then:

```text
network 192.168.101.8 0.0.0.3 area 0
```

Advertises the /30 Port-channel subnet in area 0.

```text
network 192.168.102.128 0.0.0.31 area 102
```

Places the VLAN 2 SVI into area 102.

```text
network 192.168.103.160 0.0.0.15 area 103
```

Places the VLAN 4 SVI into area 103.

## Why three OSPF areas?

The topology is intentionally a small multi-area OSPF example:

```text
                  AREA 0
            SwitchA ===== SwitchB
                  /       \
             AREA 102    AREA 103
              VLAN 2      VLAN 4
```

Both switches act as OSPF Area Border Routers (ABRs) because they have interfaces in area 0 and in non-backbone areas.

## Important distinction

The OSPF `network` command does NOT create an IP address.

The IP addresses are configured on:

- Port-channel1
- Vlan2
- Vlan4

The OSPF `network` commands tell OSPF which interfaces/subnets participate in which areas.
