# Verification and troubleshooting

## Commands to know

```text
show spanning-tree summary
show spanning-tree mst
show spanning-tree mst configuration
show spanning-tree mst 1
show spanning-tree mst 2
show spanning-tree root
show vlan brief
show interfaces trunk
show interfaces status
show spanning-tree inconsistentports
show running-config | section spanning-tree
```

Command availability and output wording vary by switch model and EVE-NG image.

## Expected results

- VLANs 10,20,30,40 are present on all three switches.
- All three trunks carry and allow VLANs 10,20,30,40.
- All switches show MST mode and matching region name/revision/VLAN-instance mapping.
- SW1 is root for MST instance 1.
- SW2 is root for MST instance 2.
- The triangle has a loop-free tree per instance, so some redundant path may be alternate/discarding.
- When one active trunk is disabled, traffic should converge through remaining links where a valid path exists.

## Troubleshooting table

| Symptom | Checks |
|---|---|
| Wrong switch is root | Check `show spanning-tree mst 1/2`; verify priority and instance number. |
| Switches not in same region | Compare name, revision, and VLAN mapping on every switch exactly. |
| VLAN traffic does not pass | Check VLAN existence, access assignment, trunk allowed list, and host IP settings. |
| Trunk not up | Verify cable/link, interface status, and trunk configuration at both ends. |
| No alternate/discarding path visible | Check the three links are actually connected and all run the intended STP mode; inspect instance output on every switch. |
| Region boundary appears | Compare the MST configuration digest and all region parameters. |
| Commands rejected | The image may be an L3 router rather than a switch, or may lack MST support. Check `show version` and `?`. |

## Safe failure test

Record the current spanning-tree state, shut one triangle link in the isolated lab, confirm alternate path/convergence, then restore it with `no shutdown`. Do not carry out topology tests on production equipment without permission.
