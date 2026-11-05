# Multi-HSRP + Port Security — EVE-NG Lab

A complete practice lab using two edge routers, two Layer-3 core switches, two Layer-3 distribution switches, and two Layer-2 access switches. It demonstrates HSRP load sharing across VLANs, routed OSPF uplinks, Rapid-PVST alignment, and switchport port security.

## Five main folders

- `configs/` — configurations for R1, R2, CSW1, CSW2, DSW1, DSW2, ASW1, ASW2
- `docs/` — addressing plan, setup walkthrough, verification and troubleshooting
- `diagrams/` — PNG and SVG topology
- `wireshark/` — capture/display filters and packet notes
- `evidence/` — place your genuine screenshots, packet captures and command outputs here

## Topology assumptions

- The name `SCSW2` in the request is interpreted as `CSW2`.
- Interface names are examples. Adjust them to your EVE-NG image and cabling before pasting configurations.
- CSW1, CSW2, DSW1, and DSW2 must use multilayer switch images that support `ip routing`, routed ports (`no switchport`), SVIs, HSRP, and OSPF.
- ASW1/ASW2 are Layer-2 switches.
- The configs use a sample OSPF underlay so the routers/core/distribution routed links can exchange routes. HSRP runs on the distribution SVIs.

## HSRP load sharing

| VLAN | Subnet | Virtual gateway | Preferred active gateway | HSRP group |
|---|---|---|---|---|
| 10 | 192.168.10.0/24 | 192.168.10.1 | DSW1 | 10 |
| 20 | 192.168.20.0/24 | 192.168.20.1 | DSW2 | 20 |
| 30 | 192.168.30.0/24 | 192.168.30.1 | DSW1 | 30 |
| 40 | 192.168.40.0/24 | 192.168.40.1 | DSW2 | 40 |

## Quick start

1. Read `docs/topology-and-addressing.md` and confirm each cable/interface.
2. Apply `configs/` one device at a time; adjust interface IDs to match your image.
3. Verify trunks and spanning tree first, then HSRP, then OSPF routing.
4. Connect hosts to ASW access ports in the desired VLAN and configure host IPs/gateways.
5. Test a port-security violation with a lab-only endpoint; a `restrict` violation drops unauthorized source-MAC traffic but leaves the interface up.
6. Capture STP/HSRP or test traffic using the filters in `wireshark/`.

## Security and compatibility notes

- Port security is configured only on host-facing access ports. Do not enable it on trunk uplinks.
- `violation restrict` is selected for easier safe lab testing. To practise err-disabled recovery, use `violation shutdown` on a test port instead.
- Cisco command support and interface naming vary by image. Check `?` and verify the switch supports the required features.
- These sample addresses and credentials (none are configured) are for isolated practice only.
- No Wireshark captures or evidence screenshots are fabricated or included; add your own artifacts to `evidence/`.
