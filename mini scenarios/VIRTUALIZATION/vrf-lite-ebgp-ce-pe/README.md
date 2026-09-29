# VRF-Lite Multi-CE eBGP Portfolio Lab

**Creator:** MohammadHadi Joshaghani  
**Focus:** Cisco VRF-Lite, multi-VRF PE-style aggregation, eBGP PE-CE routing  
**Platform:** EVE-NG

## Answer to the exam question

**Best answer: A. BGP — specifically eBGP.**

Cisco documentation says BGP, OSPF, EIGRP, RIP, and static routing can be used between a CE and PE in VRF-Lite. Cisco nevertheless recommends **external BGP (eBGP)** because it avoids needing different routing algorithms as the number of CEs grows, is designed for different administrative domains, and makes route attributes easy to pass toward the CE. citeturn290262search0turn290262search2

## Scenario

A managed-services team operates one Layer-3 switch acting as a PE-style aggregation device. Two isolated customer routing tables are required:

- `BLUE` — Customer Alpha
- `GREEN` — Customer Beta

Each VRF has its own CE router. The PE establishes a separate eBGP session inside each VRF, learns customer prefixes, and keeps the customers isolated.

The exercise intentionally includes verification and failure-injection steps so the repository demonstrates troubleshooting skills, not just a final configuration.

## Learning objectives

1. Configure two VRF-Lite instances on a multilayer switch.
2. Associate PE interfaces with the correct VRF.
3. Establish eBGP sessions between the PE and independent CEs.
4. Advertise customer LAN and loopback prefixes.
5. Verify that routes are present only in the intended VRF.
6. Troubleshoot PE-CE eBGP failures.
7. Explain why eBGP is the recommended choice in this model.

## Topology

```text
                           PE-SW / VRF-Lite
                    +-------------------------+
                    |  AS 65000               |
                    |  VRF BLUE  | VRF GREEN  |
                    +------+------------------+
                           |              |
              BLUE eBGP   |              |   GREEN eBGP
         172.31.100.0/30  |              |  172.31.200.0/30
                           |              |
                      +----+----+    +----+----+
                      |  CE-A  |    |  CE-B   |
                      | AS65101|    | AS65102 |
                      +----+---+    +----+----+
                           |              |
                 192.168.10.0/24  192.168.20.0/24
                           |              |
                         PC-A           PC-B
                     192.168.10.10   192.168.20.10
```

## Addressing plan

| Device | Interface | Address | Purpose |
|---|---|---|---|
| PE-SW | Gi1/0/1 | 172.31.100.1/30 | BLUE PE-CE link |
| PE-SW | Gi1/0/2 | 172.31.200.1/30 | GREEN PE-CE link |
| PE-SW | Loopback100 | 10.255.100.1/32 | Global router ID |
| CE-A | Gi0/0 | 172.31.100.2/30 | BLUE uplink |
| CE-B | Gi0/0 | 172.31.200.2/30 | GREEN uplink |
| CE-A | Gi0/1 | 192.168.10.1/24 | Alpha LAN gateway |
| CE-B | Gi0/1 | 192.168.20.1/24 | Beta LAN gateway |
| CE-A | Lo0 | 192.0.2.10/32 | Alpha advertised prefix |
| CE-B | Lo0 | 192.0.2.20/32 | Beta advertised prefix |
| SW-A | VLAN 10 | 192.168.10.2/24 | Alpha switch SVI |
| SW-B | VLAN 20 | 192.168.20.2/24 | Beta switch SVI |
| PC-A | NIC | 192.168.10.10/24 | GW 192.168.10.1 |
| PC-B | NIC | 192.168.20.10/24 | GW 192.168.20.1 |

## Repository layout

```text
vrf-lite-ebgp-ce-pe-portfolio/
├── README.md
├── COPYRIGHT-NOTE.md
├── LICENSE
├── MANIFEST.md
├── eve-ng/
│   ├── vrf-lite-ebgp-ce-pe-starter.unl
│   ├── vrf-lite-ebgp-ce-pe-solved.unl
│   └── IMPORT-NOTES.md
├── configs/
│   ├── starter/
│   │   ├── PE-SW.cfg
│   │   ├── CE-A.cfg
│   │   ├── CE-B.cfg
│   │   ├── SW-A.cfg
│   │   └── SW-B.cfg
│   └── solved/
│       ├── PE-SW.cfg
│       ├── CE-A.cfg
│       ├── CE-B.cfg
│       ├── SW-A.cfg
│       └── SW-B.cfg
├── docs/
│   ├── LAB-GUIDE.md
│   ├── TROUBLESHOOTING.md
│   ├── topology.drawio
│   └── topology.svg
└── verification/
    ├── commands.txt
    └── expected-state.md
```

## Step-by-step summary

### Phase 1 — Build VRF-Lite

On PE-SW:

```text
configure terminal
ip vrf BLUE
 rd 65000:101
exit
ip vrf GREEN
 rd 65000:102
exit
```

Assign each PE-facing routed interface to its VRF.

### Phase 2 — Configure PE-CE eBGP

BLUE on PE-SW:

```text
router bgp 65000
 bgp router-id 10.255.100.1
 address-family ipv4 vrf BLUE
  neighbor 172.31.100.2 remote-as 65101
  neighbor 172.31.100.2 activate
 exit-address-family
```

GREEN uses the same model with CE-B and AS 65102.

### Phase 3 — Advertise customer routes

CE-A advertises:

```text
network 192.0.2.10 mask 255.255.255.255
network 192.168.10.0 mask 255.255.255.0
```

CE-B advertises:

```text
network 192.0.2.20 mask 255.255.255.255
network 192.168.20.0 mask 255.255.255.0
```

### Phase 4 — Verify VRF separation

```text
show ip vrf
show ip route vrf BLUE
show ip route vrf GREEN
show bgp vpnv4 vrf BLUE summary
show bgp vpnv4 vrf GREEN summary
```

BLUE should contain Alpha prefixes; GREEN should contain Beta prefixes.

### Phase 5 — Troubleshoot

Shut a PE-CE interface, observe BGP and routing state, restore it, and verify recovery. The repository contains a complete troubleshooting workflow.

## Portfolio positioning

Recommended GitHub description:

> Cisco VRF-Lite multi-tenant lab demonstrating Cisco-recommended eBGP PE-CE routing across multiple VRFs, with verification and troubleshooting.

Do not describe this as a modified copy of a vendor lab. The repository is independently authored and uses new wording, topology details, device names, addressing, configuration structure, diagrams, and verification material.

Changing IP addresses alone would not necessarily make copied copyrighted text original. That is why this project was rebuilt around the underlying technical concept instead of paraphrasing the vendor's exercise line by line.

## Compatibility

The configuration targets Cisco IOS/IOS XE style syntax. Exact interface naming and some VRF/BGP command details can vary by image and software release, so map the generic image names to the IOSv/IOSvL2 images installed in your EVE-NG environment.

## Author

**MohammadHadi Joshaghani**
