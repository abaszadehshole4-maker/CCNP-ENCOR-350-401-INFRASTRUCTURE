# Verification and troubleshooting

## Verify links and addressing

```text
show ip interface brief
show ip route connected
ping 10.0.12.1
ping 10.0.12.2
ping 10.0.23.2
ping 10.0.23.3
```

## Verify EIGRP between R1 and R2

```text
show ip eigrp neighbors
show ip route eigrp
show ip protocols
```

On R2, the three R1 loopback prefixes should be EIGRP-learned before redistribution.

## Verify OSPF between R2 and R3

```text
show ip ospf neighbor
show ip ospf interface brief
show ip route ospf
```

The R2-R3 OSPF neighbor should reach FULL.

## Verify redistribution filter

On R2:

```text
show ip prefix-list EIGRP-TO-OSPF
show route-map EIGRP-TO-OSPF
show ip ospf database external
```

On R3:

```text
show ip route 10.10.10.0
show ip route 10.10.20.0
show ip route 10.10.99.0
```

Expected: two allowed routes are visible as OSPF external routes; the filtered one is not.

## Common mistakes

- **No EIGRP routes on R2:** check interface IPs, EIGRP AS 100, network statements, and neighbor state.
- **No OSPF routes on R3:** verify the OSPF neighbor is FULL, the redistribution command is under `router ospf 10`, and the route map/prefix list names match exactly.
- **All routes filtered:** prefix-list prefixes or mask lengths may be wrong. The entries here are exact `/24` matches.
- **Denied route still present on R3:** verify whether another source, static route, or previous configuration is installing it. Check OSPF LSDB as well as the RIB.
- **Command rejected:** EIGRP syntax and feature support differ among IOS/IOS XE versions; use contextual `?` help and adapt to the image.
- **Route appears with O E2:** this is expected by default. Use the optional E1 experiment only if you want to compare metric behavior.
