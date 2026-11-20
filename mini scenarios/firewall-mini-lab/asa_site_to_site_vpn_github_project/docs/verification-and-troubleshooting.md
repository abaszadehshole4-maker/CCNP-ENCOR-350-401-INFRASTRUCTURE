# Verification and troubleshooting

## 1. Verify interfaces and outside peer reachability

On both ASAs:

```text
show interface ip brief
show nameif
ping outside 203.0.113.1
```

On ASA-A the peer is `203.0.113.1`; on ASA-B it is `203.0.113.2`. The ASA ping syntax may differ slightly by release; use `ping ?` if necessary. Confirm interfaces are up/up and outside addresses are in the same `/30`.

## 2. Verify configuration

```text
show running-config crypto ikev2
show running-config crypto ipsec
show running-config crypto map
show running-config tunnel-group
show access-list S2S-TRAFFIC
```

## 3. Generate traffic

Configure Host-A as `10.10.10.10/24` with default gateway `10.10.10.1`. Configure Host-B as `10.20.20.20/24` with gateway `10.20.20.1`. Ping Host-B from Host-A. The traffic should match the VPN ACL and trigger negotiation.

## 4. Verify IKEv2 and IPsec

```text
show crypto ikev2 sa
show crypto ipsec sa
show vpn-sessiondb l2l
```

Command availability/output may vary by ASA software release. Check for an established IKEv2 SA, a peer corresponding to the other ASA, and increasing encapsulation/decapsulation counters after generating traffic.

## 5. Troubleshooting order

- **Outside ping fails:** check cabling, EVE-NG link, interface status/address/mask, and whether both peer interfaces share the same outside network.
- **IKE SA absent:** check `crypto ikev2 enable outside`, peer IP, key on both sides, compatible IKEv2 policies, licensing and the exact software/image issue.
- **IKE SA up, no IPsec SA:** check mirrored VPN ACLs, IPsec proposal compatibility and that test traffic actually crosses the ASA.
- **One direction works:** check the mirrored ACL, host default gateways, route paths, NAT and counters at both ends.
- **Counters stay at zero:** generate a new ping from the protected source subnet, then inspect `show crypto ipsec sa` again.
- **CTM ioctl error:** this is not normal successful output. Your ASA 9.1(5)16 has already shown this error. Do not assume the configuration can work while it persists; check image/platform/crypto feature support and avoid destructive boot/storage changes.
- **No host-to-host ping:** check host IP/mask/gateway and local host firewall. First test host-to-local-ASA gateway, then outside peer, then remote host.

## 6. Save configuration

Normally, ASA uses `write memory`. However, the user's previously reported ASA could not save due to a storage-space error and had a monitor-mode TFTP boot-image message. For that appliance, verify boot/storage and backup safety before relying on save or reboot operations.

## Production note

This is a contained lab example, not a production-ready security baseline. Use currently supported hardware/software and strong unique secrets in production.
