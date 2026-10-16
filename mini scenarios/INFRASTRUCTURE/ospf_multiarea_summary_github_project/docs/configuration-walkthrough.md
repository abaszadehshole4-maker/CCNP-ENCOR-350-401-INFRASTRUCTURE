# Configuration walkthrough

## 1. Configure layer 3 interfaces

Enter the interface IPs shown in `addressing-and-design.md`. Use `no shutdown` on Ethernet interfaces. Bring up serial links; if a serial interface is DCE, set a clock rate on that side only.

## 2. Enable OSPF

Each router uses `router ospf 1`, with a unique explicit router ID. The `network` statements match interface IPs and assign them to the intended areas. You can verify which interfaces are running OSPF by `show ip ospf interface brief`.

## 3. Set OSPF area membership

- Backbone Ethernet segment `10.100.100.0/24`: Area 0
- Left side: Area 1
- Right side: Area 2

Area 0 must be contiguous in normal multi-area OSPF. This diagram connects both ABRs to the shared backbone network.

## 4. Add summarization on the ABRs

On P1R1:

```text
router ospf 1
 area 1 range 192.168.1.0 255.255.255.192
```

On P2R1:

```text
router ospf 1
 area 2 range 192.168.2.0 255.255.255.192
```

These are OSPF inter-area range commands, not redistribution. If you want to advertise summaries externally redistributed into OSPF, the relevant command is `summary-address`, which is a different use case.

## 5. Confirm routes and test

After adjacencies reach FULL, inspect route tables. P1-side routers should eventually learn `192.168.2.0/26` as an inter-area route; P2-side routers should learn `192.168.1.0/26`. Ping across areas, for example from P1R3 to `192.168.2.50` and vice versa.
