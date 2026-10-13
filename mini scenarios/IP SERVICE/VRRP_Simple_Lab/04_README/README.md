# Simple Cisco VRRP Lab

**Author:** Sholeh

## Objective
Configure two routers to provide one virtual default gateway using VRRP (Virtual Router Redundancy Protocol).

## Topology
See `../02_Topology/vrrp_topology.png`.

## Addressing Plan

| Device | Interface / role | IPv4 address |
|---|---|---|
| R1 | G0/0 | `192.168.10.1/24` |
| R2 | G0/0 | `192.168.10.2/24` |
| VRRP group 10 | Virtual IP | `192.168.10.254` |
| PC1 | NIC | `192.168.10.10/24` |
| PC1 | Default gateway | `192.168.10.254` |

## Folder Contents
- `01_Config/` — R1, R2, and PC1 configuration.
- `02_Topology/` — topology diagram and text description.
- `03_Purpose_and_Explanation/` — purpose, operation, terminology, and requirements.
- `05_Wireshark/` — capture steps, display filters, and expected observations.

## Setup
1. Connect R1 G0/0, R2 G0/0, and PC1 to the same Layer 2 switch/VLAN.
2. Apply `01_Config/R1_VRRP_Master.txt` to R1.
3. Apply `01_Config/R2_VRRP_Backup.txt` to R2.
4. Configure PC1 using `01_Config/PC1_Settings.txt`.
5. Verify interface and VRRP status on both routers.
6. From PC1, ping `192.168.10.254`.

## Expected Results
- R1 should normally be Master with priority 120.
- R2 should normally be Backup with priority 100.
- PC1 uses `192.168.10.254` as its default gateway.
- If R1 stops participating in VRRP, R2 should take over after failure detection.

## Verification
Try platform-supported commands:
- `show ip interface brief`
- `show vrrp`
- `show vrrp brief`

Exact commands can vary by device and release.

## Troubleshooting
- Ensure both router interfaces are up/up.
- Ensure both routers are in the same VLAN and subnet.
- Confirm the group number and virtual IP match.
- Confirm the priorities are 120 on R1 and 100 on R2.
- Check PC1's IP, mask, and gateway.
- Check switch port VLAN assignments.

## Wireshark
See `../05_Wireshark/Wireshark_Guide.txt`.

## Note
This is a learning lab, not a complete production design. Confirm VRRP syntax and feature support for your router platform/software.
