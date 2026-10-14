# BGP Configuration Explained

## 1. AS assignments and session types

- RouterA and RouterB use `router bgp 1`.
- RouterC and RouterD use `router bgp 2`.
- RouterA–RouterB and RouterC–RouterD are iBGP sessions because the neighbor AS equals the local AS.
- RouterB–RouterC is eBGP because the local/remote AS values differ (1 and 2).

## 2. Loopback peering

`neighbor <peer-loopback> remote-as <AS>` defines the peer. `neighbor <peer-loopback> update-source Loopback0` makes the local TCP session source address the local Loopback0. Static `/32` routes make those remote loopbacks reachable. eBGP between RouterB and RouterC uses `ebgp-multihop 2` because the peer endpoints are loopbacks rather than the directly connected interface addresses.

## 3. Advertising each interface subnet

Each `network` statement lists an exact prefix/mask that should be originated into BGP. Cisco BGP does not create the route by itself: an exact matching route must already exist in the routing table. Connected interface routes and loopback routes satisfy these statements in this lab. Check with `show ip route <prefix>` if a network is not advertised.

## 4. Next-hop-self in UPDATE messages

`neighbor <peer-loopback> next-hop-self` tells the router to set itself as the next-hop for routes it advertises to that neighbor. In this scenario:

- RouterB uses `neighbor 1.1.1.1 next-hop-self` when advertising AS2 routes to RouterA.
- RouterC uses `neighbor 4.4.4.4 next-hop-self` when advertising external routes to RouterD.

This is especially useful for iBGP because routes learned over eBGP retain their external next-hop by default when passed to an iBGP peer. `next-hop-self` can make the advertising border router the usable next hop for internal peers. Exact next-hop display details can vary with platform and the session's source interface; verify with `show ip bgp <prefix>`.

## 5. Cisco BGP Weight — the key demonstration

Weight is a Cisco-proprietary, locally significant BGP attribute. It is not sent to BGP neighbors. When Cisco compares multiple BGP paths for the same prefix, the path with the **highest Weight** is preferred; Weight is the first attribute in the usual Cisco best-path sequence. Locally originated paths commonly have default weight 32768, while paths learned from peers commonly have weight 0.

RouterA and RouterD intentionally both advertise `10.99.99.0/24`. RouterB receives one path from RouterA (iBGP) and another through RouterC (eBGP). RouterB applies this inbound policy only to the duplicate demonstration prefix:

```text
ip prefix-list WEIGHT-DEMO seq 5 permit 10.99.99.0/24
route-map PREFER-AS2-IN permit 10
 match ip address prefix-list WEIGHT-DEMO
 set weight 500
route-map PREFER-AS2-IN permit 20
!
router bgp 1
 neighbor 3.3.3.3 route-map PREFER-AS2-IN in
```

The second route-map sequence permits every other prefix without changing its attributes. Without that permit-all sequence, unmatched routes would be denied by the route map.

At RouterB, inspect `show ip bgp 10.99.99.0`. The path received from RouterC should show Weight 500 and should be marked best (commonly with `>`). Compare it with the alternative path from RouterA. Weight 500 beats a default received-path weight of 0 even if other best-path attributes favor a different route.

## 6. The lab's intentional limitation

Because two different ASes originate the same `10.99.99.0/24` prefix, the demo is designed to teach path selection, not demonstrate valid unique-prefix enterprise addressing. Keep the overlapping prefix isolated and don't expect real host reachability for it to be meaningful.
