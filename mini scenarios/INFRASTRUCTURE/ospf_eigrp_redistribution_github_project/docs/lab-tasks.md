# Lab tasks

## Task 1 — Establish the routing adjacencies

1. Configure EIGRP AS 100 between R1 and R2.
2. Configure OSPF process 10, area 0 between R2 and R3.
3. Verify both adjacencies before attempting redistribution.

## Task 2 — Confirm the source routes

On R2, run `show ip route eigrp` and confirm that these routes are learned from R1:

- `10.10.10.0/24`
- `10.10.20.0/24`
- `10.10.99.0/24`

If they do not appear, troubleshoot EIGRP first.

## Task 3 — Selectively redistribute into OSPF

At R2, the policy is:

```text
ip prefix-list EIGRP-TO-OSPF seq 5 permit 10.10.10.0/24
ip prefix-list EIGRP-TO-OSPF seq 10 permit 10.10.20.0/24
!
route-map EIGRP-TO-OSPF permit 10
 match ip address prefix-list EIGRP-TO-OSPF
!
router ospf 10
 redistribute eigrp 100 subnets route-map EIGRP-TO-OSPF
```

Expected result: `10.10.10.0/24` and `10.10.20.0/24` are redistributed. `10.10.99.0/24` is not matched by a permit entry and is blocked by the prefix list's implicit deny.

## Task 4 — Verify on R3

Run:

```text
show ip route ospf
show ip route 10.10.10.0
show ip route 10.10.20.0
show ip route 10.10.99.0
show ip ospf database external
```

Expected: the first two prefixes show as OSPF external routes (usually `O E2` by default); the filtered prefix is absent from R3's routing table and OSPF external LSDB.

## Task 5 — Experiments

- Add `ip prefix-list EIGRP-TO-OSPF seq 15 permit 10.10.99.0/24` on R2, then verify that the route is now redistributed.
- Remove or re-order a permit entry and observe the effect.
- Optional: inside the route map, add `set metric 30` to control the OSPF external metric. In a separate test, add `set metric-type type-1` and observe `O E1` instead of `O E2` on R3. The exact route display can vary slightly by software release.
- Do not treat an unfiltered redistribution policy as safe for production; control what crosses protocol boundaries.
