# Verification and Troubleshooting

## Verify in this order

### 1. Interface status and addressing

Run on each router:

```text
show ip interface brief
show ip route connected
```

Expected: interfaces used for the scenario should be up/up, and connected routes should exist for their interface subnets.

### 2. Verify loopback-to-loopback reachability

Test each BGP peer before troubleshooting BGP:

- RouterA: `ping 2.2.2.2 source Loopback0`
- RouterB: `ping 1.1.1.1 source Loopback0` and `ping 3.3.3.3 source Loopback0`
- RouterC: `ping 2.2.2.2 source Loopback0` and `ping 4.4.4.4 source Loopback0`
- RouterD: `ping 3.3.3.3 source Loopback0`

If a source-interface form is not accepted by the image, try `ping` interactively and specify the source address. Confirm the relevant `/32` static route and the return path.

### 3. Verify BGP sessions

```text
show ip bgp summary
show ip bgp neighbors
```

Expected established peers:

- RouterA: `2.2.2.2`
- RouterB: `1.1.1.1` and `3.3.3.3`
- RouterC: `2.2.2.2` and `4.4.4.4`
- RouterD: `3.3.3.3`

In `show ip bgp summary`, established peers show a numeric prefix count rather than a state label such as `Idle`, `Active`, or `Connect`.

### 4. Verify advertised routes and the next hop

```text
show ip bgp
show ip bgp neighbors <peer-ip> advertised-routes
show ip bgp <prefix>
show ip route bgp
```

Look for the LAN networks, transit networks, and loopback `/32` networks configured under each router's `network` statements. On RouterA, examine a remote AS2 prefix and confirm RouterB is used as the next hop where `next-hop-self` is applied. Likewise, inspect a route at RouterD that arrives through RouterC.

`show ip bgp neighbors ... advertised-routes` behavior and command support can vary by software image.

### 5. Verify Weight preference on RouterB

```text
show ip bgp 10.99.99.0
show ip bgp neighbors 3.3.3.3 received-routes
show route-map PREFER-AS2-IN
show ip prefix-list WEIGHT-DEMO
```

The most important check is `show ip bgp 10.99.99.0`. RouterB should have two available paths for the prefix and select the RouterC-learned path with Weight 500. Look for the `>` best-path marker in typical IOS output. Output format varies by release.

### 6. Optional comparison without Weight policy

In an isolated lab, you can temporarily remove the inbound route map from RouterB to compare path selection with default received weights:

```text
configure terminal
router bgp 1
 no neighbor 3.3.3.3 route-map PREFER-AS2-IN in
end
clear ip bgp 3.3.3.3 soft in
show ip bgp 10.99.99.0
```

If your image doesn't support soft inbound refresh, use the supported route-refresh/soft-reconfiguration method for that image, or restore the route map and perform a controlled BGP refresh. Then restore the policy:

```text
configure terminal
router bgp 1
 neighbor 3.3.3.3 route-map PREFER-AS2-IN in
end
clear ip bgp 3.3.3.3 soft in
```

Do this only in the lab; resetting BGP can briefly affect routes. With the policy removed, Weight is ordinarily 0 for both learned paths, and other BGP decision criteria select the best path.

## Troubleshooting table

| Symptom | Checks |
|---|---|
| Peer stays Idle/Active | Interface status, peer `/32` route, return path, correct AS, neighbor IP, `update-source` |
| iBGP session fails over loopbacks | Static route to remote loopback exists on both peers; both sides use `update-source Loopback0` |
| RouterB–RouterC eBGP loopback session fails | `ebgp-multihop 2` configured on both sides; loopback `/32` routes; correct `remote-as` |
| A prefix is absent from BGP | Exact matching route exists in RIB, and `network` statement has correct mask |
| BGP is up but expected route missing | Check route maps, prefix list, AS_PATH loop prevention, and advertised routes |
| Weight-demo prefix has only one path | Both RouterA and RouterD have `10.99.99.0/24` in RIB and originate it; RouterB has received both paths |
| Weight is not 500 | Route map attached inbound to RouterC neighbor on RouterB; prefix list matches exact `/24`; refresh inbound route policy |
| Unexpected next hop on an iBGP peer | Check `neighbor ... next-hop-self`, the route's `show ip bgp <prefix>` output, and peer reachability |

The configurations are educational templates and have not been tested against your specific EVE-NG router image. Use `?` and verify syntax supported by your image before applying.
