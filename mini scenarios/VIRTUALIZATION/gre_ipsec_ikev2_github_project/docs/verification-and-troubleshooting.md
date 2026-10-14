# Verification and troubleshooting

## Expected successful state

- Underlay peer ping succeeds in both directions.
- `show crypto ikev2 sa` reports an established IKEv2 SA (wording varies).
- `show crypto ipsec sa` shows relevant SAs and increasing encapsulation/encryption and decapsulation/decryption counters after data traffic is sent.
- `show interfaces Tunnel0` indicates the tunnel is up/up.
- `show ip ospf neighbor` displays the other router with state FULL.
- `show ip route ospf` lists the remote LAN route.

## Troubleshooting table

| Symptom | First checks |
|---|---|
| Cannot ping underlay peer | Link status, IP/mask, cable/link in EVE-NG, interface `no shutdown` |
| IKEv2 SA not established | PSK on both ends, peer IP, `match identity remote address`, proposal/policy compatibility, image support |
| IKEv2 up but IPsec counters remain zero | Generate matching traffic, verify Tunnel0 protection profile and correct peer route |
| Tunnel0 is down | Check source interface, destination IP, underlay reachability, interface status, feature support |
| OSPF neighbor not FULL | Tunnel0 status/address, OSPF area/network config, interface MTU/hello compatibility, OSPF process active |
| Remote route missing | Confirm OSPF neighbor first, then OSPF network statements and advertised LAN subnet |
| Wireshark shows ESP but no GRE/OSPF | Expected on encrypted underlay: inner GRE/OSPF is protected; capture on tunnel/pre-encryption side if available |
| `udp.port == 500` shows no packets | The IKE SA may already exist; capture before bringing up the tunnel/rekey or trigger a fresh negotiation in the lab |

## Useful commands

```text
show ip interface brief
show ip route
show crypto ikev2 sa
show crypto ikev2 profile
show crypto ipsec sa
show interfaces Tunnel0
show ip ospf neighbor
show ip route ospf
show ip protocols
```

Some images also support debug commands, but use them cautiously: output can be extensive. If needed in an isolated lab, consult your IOS/IOS XE image's command help for IKEv2/IPsec debugging and disable debugging afterward.
