# Topology and Addressing

See `../diagrams/bgp-topology.png` or `../diagrams/bgp-topology.svg`.

## Physical / logical layout

```text
  LAN-A                 AS 1                         AS 2                LAN-D
10.1.10.0/24  RouterA -------- RouterB ======== RouterC -------- RouterD 10.2.40.0/24
                 iBGP     192.0.2.0/30   eBGP    198.51.100.0/30  iBGP
                          AS 1             AS 2                   203.0.113.0/30

BGP neighbors use Loopback0:
RouterA 1.1.1.1 <-> RouterB 2.2.2.2
RouterB 2.2.2.2 <-> RouterC 3.3.3.3 (eBGP multihop)
RouterC 3.3.3.3 <-> RouterD 4.4.4.4
```

## Addressing table

| Router | Interface | Address | Connected subnet / purpose |
|---|---|---|---|
| RouterA | G0/0 | 192.0.2.1/30 | RouterA–RouterB transit |
| RouterA | G0/1 | 10.1.10.1/24 | LAN-A |
| RouterA | Loopback0 | 1.1.1.1/32 | BGP peer ID |
| RouterA | Loopback99 | 10.99.99.1/24 | Intentional Weight-test prefix |
| RouterB | G0/0 | 192.0.2.2/30 | RouterA–RouterB transit |
| RouterB | G0/1 | 198.51.100.1/30 | RouterB–RouterC transit |
| RouterB | G0/2 | 10.1.20.1/24 | LAN-B |
| RouterB | Loopback0 | 2.2.2.2/32 | BGP peer ID |
| RouterC | G0/0 | 198.51.100.2/30 | RouterB–RouterC transit |
| RouterC | G0/1 | 203.0.113.1/30 | RouterC–RouterD transit |
| RouterC | G0/2 | 10.2.30.1/24 | LAN-C |
| RouterC | Loopback0 | 3.3.3.3/32 | BGP peer ID |
| RouterD | G0/0 | 203.0.113.2/30 | RouterC–RouterD transit |
| RouterD | G0/1 | 10.2.40.1/24 | LAN-D |
| RouterD | Loopback0 | 4.4.4.4/32 | BGP peer ID |
| RouterD | Loopback99 | 10.99.99.4/24 | Intentional Weight-test prefix |

The documentation IP blocks `192.0.2.0/24`, `198.51.100.0/24`, and `203.0.113.0/24` are reserved for examples. Use these only in the isolated lab, or replace them with your EVE-NG addressing.

## Why static routes are present

A BGP neighbor statement using a loopback address requires IP reachability to that loopback before the BGP TCP session can establish. Static `/32` routes in the router configs provide reachability to the peer loopbacks. `update-source Loopback0` makes the BGP session use each router's loopback address as its local source. RouterB–RouterC are eBGP peers using loopbacks, so both sides also use `ebgp-multihop 2`.

## Design note: overlapping demo prefix

RouterA and RouterD both have `10.99.99.0/24` connected on Loopback99 and advertise it in BGP. This deliberately creates two alternative BGP paths for the same prefix at RouterB. It is only for demonstrating Weight. Do not use overlapping address space like this for real end-to-end forwarding in production.
