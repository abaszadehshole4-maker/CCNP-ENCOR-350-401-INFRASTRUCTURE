# From zero to 100: Multi-HSRP and Port Security

## Goal

This design uses HSRP at the distribution layer to provide resilient default gateways and load-share VLANs across DSW1 and DSW2. Port security restricts the source MAC addresses allowed on host-facing ASW access ports. OSPF on routed infrastructure links supplies reachability among the routers, core and distribution layer.

## Stage 1 — Check the image and cabling

1. Use router images for R1/R2; use multilayer switch images for CSW1/CSW2/DSW1/DSW2; use Layer-2 switch images for ASW1/ASW2.
2. Verify the actual port names with `show ip interface brief` (routers/L3 switches) and `show interfaces status` (switches).
3. Confirm the links against `topology-and-addressing.md`. The configuration files assume specific interface names and cabling.

## Stage 2 — Build the L3 underlay

1. Configure R1/R2 interfaces to both core switches.
2. Configure routed interfaces on CSW1/CSW2 and DSW1/DSW2.
3. Enable `ip routing` on core/distribution multilayer switches.
4. Enable OSPF process 10 in area 0 on the routed links.
5. Verify OSPF neighbors and routes before moving on.

Commands to verify:

```text
show ip interface brief
show ip ospf neighbor
show ip route ospf
ping <neighbor-ip>
```

## Stage 3 — Create the VLANs and trunks

Create VLAN 10, 20, 30, 40, and unused native VLAN 999 on all switches that carry them. Configure the inter-distribution link and distribution-to-access links as trunks allowing `10,20,30,40,999`. Ensure both ends of each trunk have the same native VLAN.

Verify:

```text
show vlan brief
show interfaces trunk
show spanning-tree vlan 10
```

## Stage 4 — Configure STP alignment

Use Rapid-PVST in the sample. Make DSW1 root primary for VLANs 10 and 30, and DSW2 root primary for VLANs 20 and 40. The opposite switch is the secondary root. Aligning STP root with the HSRP active gateway helps avoid unnecessary L2 paths across the distribution pair.

## Stage 5 — Configure multi-HSRP

HSRP is configured on the distribution SVIs. This project uses HSRPv2.

- VLAN 10 / group 10: DSW1 preferred active; VIP `192.168.10.1`.
- VLAN 20 / group 20: DSW2 preferred active; VIP `192.168.20.1`.
- VLAN 30 / group 30: DSW1 preferred active; VIP `192.168.30.1`.
- VLAN 40 / group 40: DSW2 preferred active; VIP `192.168.40.1`.

Verify:

```text
show standby brief
show standby
```

Use the VIP—not the physical SVI address—as the client default gateway.

## Stage 6 — Configure port security

Port security belongs on host-facing access ports only. The sample allows two source MAC addresses per port, learns them with sticky learning, and uses `restrict` for violations. `restrict` drops frames from unauthorized MAC addresses, increments violation counters and generally leaves the port up.

Verify:

```text
show port-security
show port-security address
show port-security interface GigabitEthernet0/3
show logging
```

To test, attach a test endpoint and observe learned sticky MACs. If the maximum is two, a third distinct source MAC on that port should trigger a violation. Do not test against production devices.

## Stage 7 — Test failover and recovery

1. Confirm DSW1 is active for VLANs 10/30 and DSW2 for VLANs 20/40.
2. Ping between test hosts in different VLANs, using the correct virtual gateway.
3. In this isolated lab, shut both routed uplinks on the current HSRP active DSW to trigger the configured HSRP interface tracking; verify that its priority falls and its peer can take over. Restore links using `no shutdown` immediately after the test.
4. Test an access port security violation and check counters/log messages.
5. Collect outputs/screenshots for your evidence folder.

## Stage 8 — Save

On each device, review the running configuration first and then save:

```text
copy running-config startup-config
```

Command availability can vary by image. Confirm success before reloading.

## Important

The configs are learning templates rather than validated against your exact EVE-NG image. Some images use different interface names or lack HSRP, routed ports, or port-security support. Adjust and verify `?` command help before applying. Do not apply this unreviewed to production gear.
