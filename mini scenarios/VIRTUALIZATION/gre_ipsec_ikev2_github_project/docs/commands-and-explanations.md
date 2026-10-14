# From zero to working GRE-over-IPsec using IKEv2

## 0. Before configuration

- Confirm both routers are powered on and connected on the underlay.
- Make interface names match your EVE-NG image.
- Keep the lab isolated; use the example PSK only for learning.

## 1. Configure underlay and LAN interfaces

R1: `203.0.113.1/30` on G0/0, and `192.168.10.1/24` on G0/1.
R2: `203.0.113.2/30` on G0/0, and `192.168.20.1/24` on G0/1.

First run `show ip interface brief`, then test underlay reachability both ways. Do not troubleshoot IPsec until the peers can ping each other.

## 2. Build the IKEv2 configuration

- `crypto ikev2 proposal`: selects encryption, integrity, and DH group for IKE SA negotiation.
- `crypto ikev2 policy`: associates a proposal with a policy.
- `crypto ikev2 keyring`: defines a peer and the pre-shared key used to authenticate the peers.
- `crypto ikev2 profile`: identifies the peer, selects authentication, and references the keyring.

Both routers must have compatible algorithms and the matching PSK. The `match identity remote address` statement references the opposite router's underlay address.

## 3. Build IPsec protection

- `crypto ipsec transform-set GRE-TS esp-aes 256 esp-sha256-hmac`: defines ESP encryption and integrity.
- `mode transport`: selects transport mode for this common GRE-protection design.
- `crypto ipsec profile`: binds the transform set and IKEv2 profile.

Exact algorithms and accepted syntax depend on image version and policy. For current production systems, follow your organization's crypto standards rather than copying these lab choices.

## 4. Create GRE Tunnel0

`interface Tunnel0` supplies the logical tunnel interface. `tunnel source` references the local underlay interface; `tunnel destination` references the remote underlay address. `tunnel mode gre ip` enables GRE encapsulation. `tunnel protection ipsec profile` applies IPsec to traffic on the GRE tunnel.

The diagram shows outer underlay IP endpoints and the inner tunnel addresses. GRE adds an encapsulation layer; IPsec/ESP protects the GRE traffic over the underlay.

## 5. Configure OSPF over Tunnel0

OSPF process 10 advertises Tunnel0's `10.10.10.0/30` and the local LAN. Area 0 is used on both routers. `passive-interface GigabitEthernet0/1` advertises the LAN subnet but suppresses OSPF hellos on the LAN-facing port.

## 6. Verify in layers

1. Underlay: `ping` peer address.
2. IKEv2: `show crypto ikev2 sa`.
3. IPsec: `show crypto ipsec sa` and observe counters while generating traffic.
4. GRE: `show interfaces Tunnel0`.
5. OSPF: `show ip ospf neighbor` should show the peer in FULL state.
6. Routing: `show ip route ospf` should show the remote LAN route.
7. End-to-end: ping a remote LAN host or use a suitable sourced ping after routes are installed.

## 7. Save configuration

After testing and reviewing security, run `write memory` on each router.

> Example configs are provided, not guaranteed for every IOS/IOS XE image. Use `?` and image-specific command references if any command is rejected.
