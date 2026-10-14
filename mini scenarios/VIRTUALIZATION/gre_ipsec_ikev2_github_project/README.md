# GRE over IPsec with IKEv2 — EVE-NG Lab

A five-folder, GitHub-ready project for building and troubleshooting a GRE tunnel protected by IPsec using IKEv2, then running OSPF over that tunnel and inspecting the traffic in Wireshark.

## Project structure

```text
gre_ipsec_ikev2_github_project/
├── R1/         # Router 1 config and command checklist
├── R2/         # Router 2 config and command checklist
├── docs/       # Topology, addressing, setup, explanations, verification
├── wireshark/  # Display/capture filters and packet interpretation
├── evidence/   # Add your real EVE-NG PCAPNG files and screenshots here
├── README.md
└── .gitignore
```

## Scenario overview

- **R1 underlay:** `203.0.113.1/30` on G0/0
- **R2 underlay:** `203.0.113.2/30` on G0/0
- **R1 LAN:** `192.168.10.0/24`, gateway `192.168.10.1` on G0/1
- **R2 LAN:** `192.168.20.0/24`, gateway `192.168.20.1` on G0/1
- **GRE tunnel:** R1 `10.10.10.1/30`, R2 `10.10.10.2/30`
- **Security:** IKEv2 PSK authentication; ESP AES-256 with SHA-256 integrity; transport mode protecting GRE
- **Routing:** OSPF process 10, area 0, across Tunnel0

## Bring-up workflow

1. Build the topology in EVE-NG as described in `docs/topology-and-addressing.md`.
2. Confirm the underlay is working using `ping 203.0.113.2` from R1 and `ping 203.0.113.1` from R2.
3. Apply the matching config in `R1/R1.cfg` and `R2/R2.cfg` (adjust interface names and syntax to your image).
4. Verify IKEv2 with `show crypto ikev2 sa`.
5. Generate traffic and verify IPsec counters with `show crypto ipsec sa`.
6. Verify Tunnel0 and OSPF using `show interfaces Tunnel0`, `show ip ospf neighbor`, and `show ip route ospf`.
7. Capture on the **R1–R2 underlay link**, generate traffic across the tunnel, and use filters in `wireshark/`.
8. Add your own genuine `.pcapng` and screenshots under `evidence/` and describe your observations in `evidence/capture-notes-template.md`.

## Wireshark timing tip

Start the capture **before** bringing the tunnel up if you want to see the IKEv2 handshake. If the IKEv2 SA already exists, `udp.port == 500` may show no new negotiation. After the tunnel is established, generate LAN-to-LAN traffic and filter with `esp` to see protected traffic.

## Important notes
.
- `203.0.113.0/24` is reserved for documentation and should be used only in an isolated lab; replace it if your topology requires different addressing.
- The example PSK `LabOnly-ChangeThisKey-2026` is for a lab only. Change it on both routers and never commit production secrets.
- IOS and IOS XE syntax/features differ by release and image. These configurations are examples and have not been tested against your particular EVE-NG image.

## Suggested GitHub repository description

`EVE-NG lab: GRE over IPsec with IKEv2, OSPF routing, Wireshark capture filters, verification commands, and troubleshooting notes.`
