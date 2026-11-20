# Configuration walkthrough — beginner-friendly

## What type of VPN is this?

This is a policy-based site-to-site IPsec VPN between two ASA firewalls. It uses an ASA crypto map, not a GRE tunnel interface.

## Order of configuration

1. Configure outside and inside interface addressing.
2. Define the IKEv2 policy (Phase 1 negotiation).
3. Enable IKEv2 on the outside interface.
4. Define the IPsec proposal (ESP protection for data traffic).
5. Define interesting traffic with an extended ACL.
6. Configure the peer's tunnel group and matching PSK.
7. Connect the ACL, peer and proposal with a crypto map and apply it to `outside`.
8. Generate traffic between the inside LANs.

## What each command does

- `crypto ikev2 policy 10`: selects the IKEv2 algorithms and Diffie–Hellman group.
- `crypto ikev2 enable outside`: enables IKEv2 on the outside interface; it does not create a tunnel by itself.
- `crypto ipsec ikev2 ipsec-proposal S2S-PROPOSAL`: defines the ESP algorithms used to protect data traffic.
- `access-list S2S-TRAFFIC ... permit ip`: identifies traffic that should be protected by IPsec. The peer's ACL mirrors source and destination subnets in reverse order.
- `tunnel-group <peer-IP> type ipsec-l2l`: defines the remote site-to-site peer.
- `ikev2 local-authentication pre-shared-key ...` and `ikev2 remote-authentication pre-shared-key ...`: configure IKEv2 PSK authentication. Use the same lab key on both peers.
- `crypto map ... match address`: associates the ACL with a crypto-map entry.
- `crypto map ... set peer`: identifies the remote ASA.
- `crypto map ... set ikev2 ipsec-proposal`: selects the IPsec proposal for the entry.
- `crypto map ... interface outside`: applies the map to the transport interface.

## NAT note

The provided configs intentionally do not configure generic PAT, so no NAT exemption is included. If you later add dynamic NAT/PAT, exempt VPN traffic from translation using an identity-NAT rule before testing. For ASA 9.1-style object NAT, the pattern is:

```text
object network LOCAL-LAN
 subnet 10.10.10.0 255.255.255.0
object network REMOTE-LAN
 subnet 10.20.20.0 255.255.255.0
nat (inside,outside) source static LOCAL-LAN LOCAL-LAN destination static REMOTE-LAN REMOTE-LAN no-proxy-arp route-lookup
```

On ASA-B, reverse the `LOCAL-LAN` and `REMOTE-LAN` networks to match its local/remote sides. Validate this NAT rule with your exact existing NAT configuration; do not paste it blindly over existing policies.

## Algorithm/platform caveat

The IPsec proposal uses AES-256 and ESP SHA-1 integrity. This is an educational compatibility-oriented example for older ASA syntax, not a recommendation to use legacy platform/software in production. Your earlier `show version` reported `Encryption-3DES-AES: Disabled`; if that accurately reflects the active license/features, AES-based IPsec may not be available. Check the license and available algorithms first.

Also, your ASA 9.1(5)16 returned `CTM ipsec poll ctl DU_IOCTL_RESUME_POLL ioctl failed` when enabling IKEv2. If that error persists, the configuration may be present in the running config while the IPsec subsystem fails to initialize. Do not keep repeating the command or reload/erase the appliance. Confirm platform/image state, license, and boot/storage health; use a supported, known-good lab image if necessary.
