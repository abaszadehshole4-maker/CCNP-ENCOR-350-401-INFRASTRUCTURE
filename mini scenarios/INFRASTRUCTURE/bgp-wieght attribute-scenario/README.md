# Four-Router BGP Lab — iBGP, eBGP, Loopback Peering, Next-Hop-Self, and Weight

A GitHub-ready EVE-NG lab built from the supplied task list. It configures RouterA and RouterB in AS 1, RouterC and RouterD in AS 2, peers using loopback addresses, advertises interface subnets, and demonstrates how Cisco BGP **Weight** can change the selected path.

## Five project folders

- `routers/` — individual configuration files for RouterA, RouterB, RouterC, and RouterD
- `docs/` — topology/addressing, explanation, build steps, verification, and troubleshooting
- `wireshark/` — filters and capture guidance for observing BGP TCP sessions and UPDATE messages
- `evidence/` — place your real EVE-NG screenshots and packet captures here
- `diagrams/` — topology diagram in PNG and SVG formats

## Scenario summary

| Router | BGP AS | Loopback0 | LAN | Role |
|---|---:|---|---|---|
| RouterA | 1 | `1.1.1.1/32` | `10.1.10.0/24` | AS 1 internal BGP peer |
| RouterB | 1 | `2.2.2.2/32` | `10.1.20.0/24` | AS 1 peer and AS border router |
| RouterC | 2 | `3.3.3.3/32` | `10.2.30.0/24` | AS 2 peer and AS border router |
| RouterD | 2 | `4.4.4.4/32` | `10.2.40.0/24` | AS 2 internal BGP peer |

RouterA–RouterB use iBGP in AS 1. RouterC–RouterD use iBGP in AS 2. RouterB–RouterC use eBGP between AS 1 and AS 2. Every BGP session uses loopback addresses as the neighbor endpoints.

## Before you start

- Use an IOS/IOS XE image that supports classic IPv4 BGP, route maps, prefix lists, and loopback interfaces. Syntax/output can vary between images.
- Interface names in this package are `GigabitEthernet0/0`, `GigabitEthernet0/1`, and (on RouterB/RouterC) `GigabitEthernet0/2`. Adapt them to your EVE-NG image.
- Interfaces are assumed to be cabled as shown and the supplied IP addresses are applied by these configs.
- Loopback reachability for BGP TCP sessions is provided by static `/32` routes. This is intentional to keep the exercise focused on BGP rather than add a separate IGP.
- All interface-connected subnets, including loopbacks and transit links, are included in the BGP `network` statements. A `network` statement advertises a prefix only when an exact matching route exists in the routing table.

## Quick start

1. Build the topology from `docs/topology-and-addressing.md`.
2. Apply `routers/RouterA/RouterA.cfg`, then B, C, and D. Adapt interface names if needed.
3. Verify loopback reachability with the static routes before troubleshooting BGP.
4. Check neighbor state using `show ip bgp summary`.
5. Check learned networks and the weight demonstration using the commands in `docs/verification-and-troubleshooting.md`.
6. To observe packets, capture the router-to-router links and follow `wireshark/capture-guide.md`.
7. Put your own captures and screenshots in `evidence/`.

## Important note on the Weight demonstration

To produce **two BGP paths for the same prefix** at RouterB, RouterA and RouterD intentionally both advertise `10.99.99.0/24` using Loopback99. That overlapping prefix is a lab-only trick for showing best-path selection, not a recommended production addressing design. RouterB assigns weight `500` to the path for this prefix received from RouterC. The higher-weight path should be selected at RouterB.

Cisco Weight is local to the router and is not propagated to BGP neighbors. On Cisco platforms, the highest weight is preferred, and Weight is checked first in the usual BGP best-path decision sequence. A locally originated route typically has a default weight of `32768`; routes learned from neighbors typically start at `0`, unless changed by policy.

## Evidence and safety

No personal EVE-NG packet captures were attached to this request, so the `evidence/` folder contains an evidence checklist, not fabricated packet captures. Add your own `.pcapng` files/screenshots after running the lab. Avoid committing credentials, private information, or production traffic.
