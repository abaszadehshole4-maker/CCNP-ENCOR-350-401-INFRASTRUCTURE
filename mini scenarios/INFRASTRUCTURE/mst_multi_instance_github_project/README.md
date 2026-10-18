# Cisco MST (Multiple Spanning Tree) — EVE-NG Lab

A complete, GitHub-ready lab for practising Multiple Spanning Tree Protocol (MST / IEEE 802.1s) on three Cisco IOS/IOS XE Layer-2 switches. The triangle topology creates redundant Layer-2 paths, allowing you to observe different root bridges and blocked/alternate ports per MST instance.

## Five main folders

- `configs/` — complete per-switch configurations for SW1, SW2, SW3
- `docs/` — topology/addressing assumptions, setup from zero, explanations, tasks, verification, and troubleshooting
- `diagrams/` — topology in PNG and SVG
- `wireshark/` — capture/display filters and BPDU interpretation
- `evidence/` — add your genuine CLI screenshots and packet captures here

## Lab goals

1. Create VLANs 10, 20, 30, 40 and trunk them across the triangle.
2. Put all switches in the same MST region by matching the name, revision, and VLAN-to-instance map.
3. Map VLANs 10 and 20 to MST instance 1, and VLANs 30 and 40 to MST instance 2.
4. Make SW1 the root for instance 1 and SW2 the root for instance 2.
5. Verify port roles/states, region consistency, VLAN trunks, and convergence after a link failure.
6. Capture STP/MST BPDUs in Wireshark.

## Topology

```text
                  Gi0/0                 Gi0/0
             +------------ SW1 ----------------+
             |             /  \                |
             |            /    \ Gi0/1         |
      Gi0/0  |           /      \               | Gi0/1
       SW2 --+----------/--------\-------------- SW3
         \           Gi0/0?       
          \__ SW2 Gi0/1 ---- SW3 Gi0/0 __/
```

Use the exact connection table and generated diagram in `docs/topology-and-addressing.md`; this ASCII sketch is only a reminder that the three switches form a triangle.

## Quick start

1. Add three supported Cisco IOS/IOS XE Layer-2 switch nodes in EVE-NG.
2. Connect links exactly as shown in `docs/topology-and-addressing.md`.
3. Check actual interface names with `show interfaces status` or `show ip interface brief`; adapt `GigabitEthernet0/x` if your image uses another convention.
4. Apply each file in `configs/` to the matching switch.
5. Verify MST region configuration, trunks, root bridges and instance port states using `docs/verification-and-troubleshooting.md`.
6. Capture a switch-to-switch link in EVE-NG to observe BPDUs using filters in `wireshark/`.

## Important notes

- All three switches must have exactly matching MST region name, revision number, and VLAN-to-instance mappings. A mismatch can place a switch outside the intended region.
- The configs are educational templates, not tested against your exact EVE-NG image. Interface naming and supported CLI syntax vary by image.
- Do not use production switches without authorization. Apply VLAN/trunk/STP changes in an isolated lab first.
- The `evidence/` directory is intentionally a placeholder; no captures were supplied, so no fabricated packet captures are included.
