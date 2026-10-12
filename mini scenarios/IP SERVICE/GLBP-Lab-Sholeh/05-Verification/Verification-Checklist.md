# GLBP Lab — Verification and Troubleshooting

**Author: Sholeh**

Work through the checks in order. Command output varies by IOS/IOS XE release; look for the stated behavior rather than expecting identical spacing or timers.

## Stage 1 — Confirm links and IP addresses

On R1, R2, and R3:

```text
show ip interface brief
```

Expected: the configured interfaces are `up/up` after all cables/links are connected and interfaces are enabled. If an interface is `administratively down`, enter that interface and issue `no shutdown`. If it is `down/down`, check the cable, switch port, or lab link.

From PC1 and PC2, confirm the following address settings:

| PC | Address | Mask | Default gateway |
|---|---|---|---|
| PC1 | `192.168.10.11` | `255.255.255.0` | `192.168.10.1` |
| PC2 | `192.168.10.12` | `255.255.255.0` | `192.168.10.1` |

## Stage 2 — Verify the GLBP group

Run on **R1 and R2**:

```text
show glbp brief
show glbp 10
```

Expected behavior:

- Group `10` appears on the LAN interface (`GigabitEthernet0/0`, or your image's equivalent).
- The virtual IP is `192.168.10.1`.
- R1 should normally be the Active Virtual Gateway (AVG) because its priority is `120`, while R2 is configured with `100`.
- Both routers should be participating in the group. With both healthy, you should see virtual forwarder information; the number/state shown depends on the platform and release.
- Load balancing should indicate `round-robin`.

If `show glbp` is unrecognized, the router image may not support GLBP or may use a different feature set. Confirm support with `glbp ?` under interface configuration mode.

## Stage 3 — Verify routing to the lab destination

On R1 and R2:

```text
show ip route 203.0.113.1
ping 203.0.113.1
```

On R3:

```text
show ip route 192.168.10.0
ping 10.0.12.1
ping 10.0.23.1
```

Expected: R1 and R2 have a route to `203.0.113.1` via their respective R3 link. R3 should have equal-cost paths to `192.168.10.0/24` while both upstream links are available.

From each PC, use its command prompt:

```text
ping 192.168.10.1
ping 192.168.10.2
ping 192.168.10.3
ping 203.0.113.1
```

The first ping can time out while ARP is being resolved. Repeat the test. The physical-router pings (`.2` and `.3`) are useful diagnostics; PCs must still use `192.168.10.1` as their gateway.

## Stage 4 — Observe virtual MAC assignments

On each PC, inspect its ARP table after pinging the gateway:

- Windows: `arp -a`
- To clear cached ARP entries on Windows before repeating: `arp -d *` from an elevated command prompt, then ping `192.168.10.1` again.
- In a simulator PC that does not support these exact commands, use its ARP/command tools or wait for the ARP cache entry to expire.

The entry for `192.168.10.1` should map to a GLBP virtual MAC address, not necessarily the physical MAC address of either router. With round-robin, the AVG rotates the virtual forwarder used in ARP replies. Two PCs may receive different virtual MACs, but this is not guaranteed for every test run because of ARP timing and cache state.

## Stage 5 — Test gateway failover

1. Confirm both routers show the GLBP group and save or note the current output.
2. **Power off / stop the R1 router node** in the lab (rather than shutting only its LAN interface). This also takes down R1's upstream link in this topology.
3. Wait for GLBP detection and role change timers to expire.
4. On R2, run:

   ```text
   show glbp 10
   show glbp brief
   ```

5. From PC1, repeat `ping 192.168.10.1` and `ping 203.0.113.1`. Some packet loss during convergence is normal.
6. Start R1 again. Wait for its interfaces and GLBP group to recover, then check whether R1 returns to the preferred AVG role because `glbp 10 preempt` is configured.

**Why power off the whole R1 node for this test?** The baseline lab's upstream routing uses static routes. Taking down only R1's LAN interface does not necessarily remove its upstream next hop from R3. Whole-node failure makes the redundant upstream path behavior easier to validate. Upstream-interface tracking is a useful follow-on exercise.

## Common problems

| Symptom | Check |
|---|---|
| `show glbp` shows no group | Verify GLBP support, interface status, group number, and `glbp 10 ip 192.168.10.1` on both routers. |
| Routers do not see each other | Confirm both LAN interfaces connect to the same Layer 2 VLAN/broadcast domain and matching group number. |
| PC cannot ping `192.168.10.1` | Check PC address/mask/gateway, switch connections, `show ip interface brief`, and `show glbp 10`. |
| PC can ping gateway but not `203.0.113.1` | Check both router static routes, R3's loopback, R3's return routes, and upstream interface states. |
| Only one router forwards host traffic | Check both routers' GLBP group/forwarder status and load-balancing configuration. Remember that host ARP caches can keep an existing assignment. |
| Config commands are rejected | Check that your image supports GLBP and adapt interface names / IOS syntax to that platform. |

## Completion criteria

- [ ] R1 and R2 have working LAN and upstream interfaces.
- [ ] Both routers participate in GLBP group 10 with virtual IP `192.168.10.1`.
- [ ] R1 is normally the preferred AVG.
- [ ] Round-robin is shown as the load-balancing method.
- [ ] Both PCs can ping the virtual gateway and `203.0.113.1`.
- [ ] R2 assumes the AVG role when R1 is stopped, after convergence.
- [ ] The lab configuration and verification output are saved for the portfolio.
