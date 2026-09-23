# SwitchA — complete command sequence from zero

```text
enable
configure terminal

hostname SwitchA

ip routing

vlan 2
 name VLAN2
exit

vlan 4
 name VLAN4
exit

interface range FastEthernet0/1 - 2
 no switchport
 channel-group 1 mode on
 no shutdown
exit

interface Port-channel1
 no switchport
 ip address 192.168.101.10 255.255.255.252
 no shutdown
exit

interface Vlan2
 ip address 192.168.102.129 255.255.255.224
 no shutdown
exit

interface Vlan4
 ip address 192.168.103.171 255.255.255.240
 no shutdown
exit

interface FastEthernet0/3
 switchport mode access
 switchport access vlan 2
 spanning-tree portfast
 no shutdown
exit

interface FastEthernet0/4
 switchport mode access
 switchport access vlan 4
 spanning-tree portfast
 no shutdown
exit

router ospf 10
 network 192.168.101.8 0.0.0.3 area 0
 network 192.168.102.128 0.0.0.31 area 102
 network 192.168.103.160 0.0.0.15 area 103
exit

end

show ip interface brief
show etherchannel summary
show ip ospf neighbor
show ip route ospf

ping 192.168.101.9

copy running-config startup-config
```

## SwitchB — matching configuration for the scenario

```text
enable
configure terminal

hostname SwitchB
ip routing

vlan 2
 name VLAN2
exit

vlan 4
 name VLAN4
exit

interface range FastEthernet0/1 - 2
 no switchport
 channel-group 1 mode on
 no shutdown
exit

interface Port-channel1
 no switchport
 ip address 192.168.101.9 255.255.255.252
 no shutdown
exit

interface Vlan2
 ip address 192.168.102.130 255.255.255.224
 no shutdown
exit

interface Vlan4
 ip address 192.168.103.172 255.255.255.240
 no shutdown
exit

interface FastEthernet0/3
 switchport mode access
 switchport access vlan 2
 spanning-tree portfast
 no shutdown
exit

interface FastEthernet0/4
 switchport mode access
 switchport access vlan 4
 spanning-tree portfast
 no shutdown
exit

router ospf 10
 network 192.168.101.8 0.0.0.3 area 0
 network 192.168.102.128 0.0.0.31 area 102
 network 192.168.103.160 0.0.0.15 area 103
exit

end

show ip interface brief
show etherchannel summary
show ip ospf neighbor
show ip route ospf

ping 192.168.101.10

copy running-config startup-config
```
