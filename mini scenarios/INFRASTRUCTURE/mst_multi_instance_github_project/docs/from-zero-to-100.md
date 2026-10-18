# MST lab: from zero to 100

## Goal

Build a three-switch redundant Layer-2 topology and run MST with two instances so VLAN groups can have different root bridges and forwarding paths.

## Step 1 — Build EVE-NG topology

Create three supported Cisco IOS/IOS XE Layer-2 switch nodes: SW1, SW2, SW3. Connect the three trunk links exactly as listed in `topology-and-addressing.md`. Optionally connect endpoint/host nodes to the access ports.

## Step 2 — Identify interface names

On each switch, before applying the config:

```text
show version
show interfaces status
show vlan brief
show spanning-tree summary
```

Some EVE-NG images use `Ethernet0/x`, `GigabitEthernet0/x`, or other interface names. If needed, adapt the config to the interfaces actually present.

## Step 3 — Apply each switch configuration

Open the switch console and enter privileged/config mode:

```text
enable
configure terminal
```

Paste the matching config from `configs/SW1.cfg`, `configs/SW2.cfg`, or `configs/SW3.cfg`. Check for rejected commands before continuing. On images that don't support a command, use `?` and consult the documentation for that specific image.

## Step 4 — Understand the VLANs and trunks

VLANs 10 and 20 are mapped to MST instance 1. VLANs 30 and 40 are mapped to MST instance 2. The trunks carry all four VLANs. Access ports carry one untagged VLAN for endpoints.

## Step 5 — Understand region matching

MST region identity depends on the region name, revision, and VLAN-to-instance mapping (configuration digest). All switches intended to be in the same region must match these. One typo in the name/revision/map can create a region boundary.

Check on every switch:

```text
show spanning-tree mst configuration
show spanning-tree mst
```

## Step 6 — Confirm root bridges and port roles

On SW1:

```text
show spanning-tree mst 1
show spanning-tree mst 2
```

Repeat on SW2 and SW3. SW1 should be root for instance 1 and SW2 should be root for instance 2, assuming the configurations applied correctly. On non-root switches, expect root ports toward the instance's root and at least one alternate/discarding path around the redundant triangle. Exact port roles depend on interface cost, port IDs, and platform behavior.

## Step 7 — Verify trunks and VLANs

```text
show vlan brief
show interfaces trunk
show spanning-tree inconsistentports
```

Ensure VLANs 10,20,30,40 exist and are permitted on all inter-switch trunks. If your image does not implement one command, use the available equivalent.

## Step 8 — Test convergence

1. Capture a switch-to-switch link in EVE-NG/Wireshark.
2. Record MST status on all switches.
3. Shut down one redundant trunk interface, for example on SW3:

```text
configure terminal
interface GigabitEthernet0/1
 shutdown
end
```

4. Check that MST recomputes the tree and connectivity recovers over the remaining path.
5. Restore the link:

```text
configure terminal
interface GigabitEthernet0/1
 no shutdown
end
```

Only shut down links in your isolated lab. Do not do this on a production switch without authorization.

## Step 9 — Save configurations

```text
copy running-config startup-config
```

Answer any confirmation prompt as instructed by the device. Verify with `show startup-config` if supported.

## Step 10 — Document results

Save genuine screenshots of `show spanning-tree mst`, `show spanning-tree mst configuration`, `show interfaces trunk`, and the Wireshark BPDU capture into `evidence/`. Include the test performed and what changed after the link was shut/no-shut.
