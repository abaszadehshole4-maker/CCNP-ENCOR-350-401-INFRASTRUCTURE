# EIGRP-to-OSPF Redistribution with Prefix Lists and Route Maps

A GitHub-ready EVE-NG lab that demonstrates selective redistribution of EIGRP routes into OSPF. R2 is the redistribution boundary router. An IP prefix list and route map allow only selected EIGRP prefixes into OSPF; the remaining EIGRP prefixes are filtered.

## Five main folders

- `routers/` — ready-to-review configurations for R1, R2, and R3
- `docs/` — topology, addressing plan, command-by-command explanations, tasks, verification, and troubleshooting
- `wireshark/` — capture filters and what to expect when observing OSPF/EIGRP
- `evidence/` — place your real screenshots and capture files here
- `diagrams/` — topology diagram in PNG and SVG

## Learning goals

1. Configure EIGRP AS 100 between R1 and R2.
2. Configure OSPF process 10, area 0 between R2 and R3.
3. Redistribute EIGRP-learned routes into OSPF at R2.
4. Use a prefix list plus route map to permit only selected prefixes.
5. Confirm permitted prefixes appear as OSPF external routes and a filtered prefix does not appear on R3.
6. Compare the default OSPF external type (E2) with an optional E1 experiment.

## Topology at a glance

```text
R1 (EIGRP AS 100) ---- R2 (EIGRP + OSPF redistribution) ---- R3 (OSPF area 0)
Loopbacks:                                                     OSPF client
10.10.10.0/24  permit
10.10.20.0/24  permit
10.10.99.0/24  filtered
```

See `diagrams/topology.png` and `docs/topology-and-addressing.md`.

## Recommended workflow

1. Start the three routers and use the interface names documented in this project (adapt if your EVE-NG image uses other names).
2. Apply R1, R2, and R3 configs.
3. Confirm EIGRP adjacency between R1 and R2, and OSPF adjacency between R2 and R3.
4. On R2, check that EIGRP has learned all three R1 loopback prefixes.
5. On R3, confirm `10.10.10.0/24` and `10.10.20.0/24` appear as OSPF external routes, while `10.10.99.0/24` does not.
6. Complete the tasks in `docs/lab-tasks.md` and capture your own evidence.

## Important concepts

- Redistribution occurs on R2, which runs both routing protocols.
- The prefix list uses `permit` entries for the routes that should be redistributed. Prefixes not matched by a permitted entry are denied by the prefix list's implicit deny.
- The route map matches the prefix list, and `redistribute eigrp 100 subnets route-map EIGRP-TO-OSPF` applies the policy.
- OSPF external routes are normally E2 unless you set the external metric type to E1.

## Safety and compatibility

This is an educational template, not a production design. IOS/IOS XE versions can vary in command support and output. Use `?` and check the documentation for your exact EVE-NG image. The sample networks are private lab ranges. No real packet captures were attached, so `evidence/` contains instructions only; add your actual screenshots/captures yourself.
