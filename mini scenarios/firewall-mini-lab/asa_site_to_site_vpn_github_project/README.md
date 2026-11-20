# Cisco ASA Site-to-Site IPsec VPN (IKEv2) — EVE-NG Lab

A beginner-friendly, GitHub-ready project demonstrating a **policy-based site-to-site IPsec VPN between two Cisco ASA firewalls using IKEv2 and pre-shared-key authentication**.

## Five main folders

- `configs/` — complete example configurations for ASA-A and ASA-B
- `docs/` — topology, addressing, configuration walkthrough, verification, troubleshooting, and platform notes
- `diagrams/` — topology diagram in PNG and SVG
- 
- `evidence/` — place for your own captures and screenshots

## Important note for your specific ASA 5520

You previously reported **ASA 9.1(5)16**, an image status of `Unknown, monitor mode tftp booted image`, a configuration-save space error, the license line `Encryption-3DES-AES: Disabled`, and this error when enabling IKEv2:

```text
ERROR: CTM ipsec poll ctl DU_IOCTL_RESUME_POLL ioctl failed.
```

Those issues are separate from the site-to-site VPN command sequence. This project shows a standards-based ASA 9.1-style IKEv2 configuration, but **it cannot guarantee your current image will negotiate a VPN**. In particular, if AES/3DES encryption is not enabled for the image/license, or the IKE/IPsec subsystem is failing, the tunnel will not establish just because the configuration is present. Do not reload, erase flash, or change boot settings on the affected appliance until its image, license, and saved configuration are safe.

## Topology summary

| Item | ASA-A (your current ASA1 can use these values) | ASA-B |
|---|---|---|
| Outside interface | `Ethernet0` | `Ethernet0` |
| Outside IP | `203.0.113.2/30` | `203.0.113.1/30` |
| Inside interface | `Ethernet1` | `Ethernet1` |
| Inside IP | `10.10.10.1/24` | `10.20.20.1/24` |
| Protected LAN | `10.10.10.0/24` | `10.20.20.0/24` |
| IKEv2 peer | `203.0.113.1` | `203.0.113.2` |

Documentation IP range `203.0.113.0/24` is reserved for examples. Keep this topology in an isolated lab; replace addresses if your real network uses them.

## Quick workflow

1. Connect each ASA `Ethernet0` to the shared outside/transport network and each `Ethernet1` to its local LAN.
2. Confirm outside peer reachability before VPN configuration.
3. Apply the matching configuration to both peers, checking interface names and licensing first.
4. Connect a VPCS/host to each inside LAN and set its default gateway to the local ASA inside IP.
5. Generate LAN-to-LAN traffic to trigger the VPN.
6. Verify IKEv2, IPsec counters, and end-to-end pings.
7. Capture IKE/ESP traffic using the Wireshark guide.
8. Add only your genuine lab evidence in `evidence/`.

## Security and learning notes

- The sample pre-shared key is **lab-only**. Replace it on both peers, and never reuse it in production.
- The configuration intentionally uses the classic ASA **crypto-map** model; it does not create a GRE tunnel interface.
- The two VPN ACLs must be mirror images.
- The example does not configure generic dynamic PAT. If you later add NAT/PAT rules, add an identity-NAT exemption for VPN traffic before testing.
- Validate commands against the exact ASA release and platform. Some algorithms/features vary by model, software release, and license.

## Cisco reference

See Cisco's ASA 9.1 LAN-to-LAN VPN guide: https://www.cisco.com/c/en/us/td/docs/security/asa/asa91/configuration/vpn/asa_91_vpn_config/vpn_site2site.html
