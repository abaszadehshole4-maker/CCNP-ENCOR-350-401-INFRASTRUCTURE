# Topology and Port Map

## Devices

- R1-EDGE
- R2-TRANSIT
- R3-REMOTE
- SW1-DIST-A
- SW2-DIST-B
- SW3-ACCESS-B
- FIN-PC1
- ENG-PC1
- FIN-PC2
- ENG-PC2

## Logical topology

```text
FIN-PC1 --- SW1-DIST-A ===== SW2-DIST-B --- FIN-PC2
              |       \       /              |
              |        \ L2  /               |
          R1-EDGE ---- R2-TRANSIT ---- R3-REMOTE
              |                         |
           FIN/ENG                   FIN/ENG
              |                         |
          user VLANs                user VLANs
```

The routers carry both VRFs on VLAN subinterfaces:

```text
Gi0/1.110 = FINANCE   dot1q 110
Gi0/1.120 = ENGINEERING dot1q 120
```

The router-to-router WAN transit uses separate physical point-to-point interfaces.

## Router addressing

### R1-EDGE

- Gi0/2.110 — FINANCE: `10.44.110.1/24`, `2001:db8:44:110::1/64`
- Gi0/2.120 — ENGINEERING: `10.44.120.1/24`, `2001:db8:44:120::1/64`
- Gi0/0 — TRANSIT FINANCE: `172.30.10.1/30`, `2001:db8:44:10::1/64`
- Gi0/1 — TRANSIT ENGINEERING: `172.30.20.1/30`, `2001:db8:44:20::1/64`
- Gi0/2 — 802.1Q trunk toward SW1-DIST-A

### R2-TRANSIT

- Gi0/0 — towards R1, FINANCE: `172.30.10.2/30`
- Gi0/1 — towards R1, ENGINEERING: `172.30.20.2/30`
- Gi0/2 — towards R3, FINANCE: `172.30.30.1/30`
- Gi0/3 — towards R3, ENGINEERING: `172.30.40.1/30`

### R3-REMOTE

- Gi0/2.110 — FINANCE: `10.55.110.1/24`, `2001:db8:55:110::1/64`
- Gi0/2.120 — ENGINEERING: `10.55.120.1/24`, `2001:db8:55:120::1/64`
- Gi0/1 — from R2, FINANCE: `172.30.30.2/30`
- Gi0/2 — from R2, ENGINEERING: `172.30.40.2/30`

## Host addressing

| Host | VLAN/VRF | IPv4 | Gateway | IPv6 | Gateway |
|---|---|---|---|---|---|
| FIN-PC1 | 110 / FINANCE | 10.44.110.50/24 | 10.44.110.1 | 2001:db8:44:110::50/64 | 2001:db8:44:110::1 |
| ENG-PC1 | 120 / ENGINEERING | 10.44.120.50/24 | 10.44.120.1 | 2001:db8:44:120::50/64 | 2001:db8:44:120::1 |
| FIN-PC2 | 110 / FINANCE | 10.55.110.50/24 | 10.55.110.1 | 2001:db8:55:110::50/64 | 2001:db8:55:110::1 |
| ENG-PC2 | 120 / ENGINEERING | 10.55.120.50/24 | 10.55.120.1 | 2001:db8:55:120::50/64 | 2001:db8:55:120::1 |

## Switch port map

### SW1-DIST-A

- Gi0/0 ↔ R1-EDGE Gi0/0 (802.1Q trunk)
- Gi0/1 ↔ ENG-PC1 (access VLAN 120)
- Gi0/2 ↔ FIN-PC1 (access VLAN 110)
- Gi0/3 ↔ SW3-ACCESS-B Gi0/0 (LACP member)
- Gi0/4 ↔ SW3-ACCESS-B Gi0/1 (LACP member)

### SW2-DIST-B

- Gi0/0 ↔ R3-REMOTE Gi0/0 (802.1Q trunk)
- Gi0/1 ↔ ENG-PC2 (access VLAN 120)
- Gi0/2 ↔ FIN-PC2 (access VLAN 110)

### SW3-ACCESS-B

- Gi0/0 ↔ SW1-DIST-A Gi0/3 (LACP member)
- Gi0/1 ↔ SW1-DIST-A Gi0/4 (LACP member)
- Gi0/2 reserved for additional lab host
- Gi0/3 reserved for additional lab host

## Design note

The VRF boundary is at the routers. VLANs carry the two user groups toward the router-on-a-stick subinterfaces. The access switches do not need VRFs.
