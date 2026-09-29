# BGP Experiments — exact command sequence

> Start from the baseline configurations. After each experiment, remove the policy before moving to the next experiment unless the experiment explicitly says to keep it.

## 0. Baseline

On R1:

```cisco
show ip bgp summary
show ip bgp 203.0.113.0
show ip route 203.0.113.0
```

You should see three candidate paths for `203.0.113.0/24` after convergence:
- via R3 / AS65010
- via R4 / AS65020
- via R2 / R5 / AS65030

---

## 1. Weight — highest wins

R1:

```cisco
ip prefix-list DEST seq 5 permit 203.0.113.0/24
!
route-map ISP1-WEIGHT permit 10
 match ip address prefix-list DEST
 set weight 500
!
router bgp 65001
 neighbor 10.0.13.2 route-map ISP1-WEIGHT in
```

Verify:

```cisco
show ip bgp 203.0.113.0
```

Expected: the R3 path has Weight `500` and becomes best.

Reset:

```cisco
router bgp 65001
 no neighbor 10.0.13.2 route-map ISP1-WEIGHT in
```

---

## 2. Local Preference — highest wins

R1:

```cisco
route-map ISP2-LOCALPREF permit 10
 match ip address prefix-list DEST
 set local-preference 200
!
router bgp 65001
 neighbor 10.0.14.2 route-map ISP2-LOCALPREF in
```

Verify:

```cisco
show ip bgp 203.0.113.0
```

Expected: the R4 path wins because Local Preference `200 > 100`.

Reset:

```cisco
router bgp 65001
 no neighbor 10.0.14.2 route-map ISP2-LOCALPREF in
```

---

## 3. AS_PATH — shortest wins

On R3:

```cisco
route-map ISP1-PREPEND permit 10
 match ip address prefix-list DEST
 set as-path prepend 65010 65010 65010
!
router bgp 65010
 neighbor 10.0.13.1 route-map ISP1-PREPEND out
```

R1:

```cisco
clear ip bgp 10.0.13.2 soft out
show ip bgp 203.0.113.0
```

Expected: ISP1's path is longer and loses if higher-priority attributes are equal.

Reset on R3:

```cisco
router bgp 65010
 no neighbor 10.0.13.1 route-map ISP1-PREPEND out
clear ip bgp 10.0.13.1 soft out
```

---

## 4. ORIGIN — IGP < EGP < Incomplete

Create the prefix list on R4 and R5:

```cisco
ip prefix-list DEST seq 5 permit 203.0.113.0/24
```

R4:

```cisco
route-map SET-EGP permit 10
 match ip address prefix-list DEST
 set origin egp
!
router bgp 65020
 neighbor 10.0.14.1 route-map SET-EGP out
```

R5:

```cisco
route-map SET-INCOMPLETE permit 10
 match ip address prefix-list DEST
 set origin incomplete
!
router bgp 65030
 neighbor 10.0.25.1 route-map SET-INCOMPLETE out
```

Refresh:

```cisco
clear ip bgp 10.0.14.1 soft out
clear ip bgp 10.0.25.1 soft out
```

On R1:

```cisco
show ip bgp 203.0.113.0
```

If all earlier attributes are equal, the path with origin `i` is preferred over `e`, which is preferred over `?`.

Reset:

```cisco
router bgp 65020
 no neighbor 10.0.14.1 route-map SET-EGP out
!
router bgp 65030
 no neighbor 10.0.25.1 route-map SET-INCOMPLETE out
```

---

## 5. MED — lowest wins

For a clear MED-only experiment, first ensure Weight, Local Preference, AS_PATH and ORIGIN are equal.

R3:

```cisco
route-map ISP1-MED permit 10
 match ip address prefix-list DEST
 set metric 50
!
router bgp 65010
 neighbor 10.0.13.1 route-map ISP1-MED out
```

R4:

```cisco
route-map ISP2-MED permit 10
 match ip address prefix-list DEST
 set metric 100
!
router bgp 65020
 neighbor 10.0.14.1 route-map ISP2-MED out
```

R1:

```cisco
router bgp 65001
 bgp always-compare-med
```

Refresh:

```cisco
clear ip bgp 10.0.13.2 soft in
clear ip bgp 10.0.14.2 soft in
```

Verify:

```cisco
show ip bgp 203.0.113.0
```

Expected: MED `50` is preferred over MED `100`, assuming all preceding attributes are equal.

Reset:

```cisco
router bgp 65001
 no bgp always-compare-med
 no neighbor 10.0.13.2 route-map ISP1-MED out
 no neighbor 10.0.14.2 route-map ISP2-MED out
```

On R3/R4 remove the corresponding route-map neighbors.

---

## 6. Route filtering — accept only one prefix

R1 should accept only `203.0.113.0/24` from ISP1 and reject `198.51.100.0/24`.

R1:

```cisco
ip prefix-list ISP1-IN seq 5 permit 203.0.113.0/24
!
router bgp 65001
 neighbor 10.0.13.2 prefix-list ISP1-IN in
```

Refresh:

```cisco
clear ip bgp 10.0.13.2 soft in
```

Verify:

```cisco
show ip bgp
show ip bgp 203.0.113.0
show ip bgp 198.51.100.0
show ip bgp neighbors 10.0.13.2 received-routes
show ip bgp neighbors 10.0.13.2 routes
```

Expected:
- `203.0.113.0/24` is accepted from ISP1.
- `198.51.100.0/24` is filtered from ISP1.

Important distinction:
- `received-routes` shows routes received before inbound policy when soft-reconfiguration is enabled.
- `routes` shows routes accepted after inbound policy.

---

## 7. Outbound route filtering

Example: allow only `203.0.113.0/24` toward ISP1.

R1:

```cisco
ip prefix-list CUSTOMER-OUT seq 5 permit 203.0.113.0/24
!
router bgp 65001
 neighbor 10.0.13.2 prefix-list CUSTOMER-OUT out
```

Verify:

```cisco
show ip bgp neighbors 10.0.13.2 advertised-routes
```

This is an important portfolio demonstration because it shows that route filtering can be applied in either direction.

---

## 8. Route-map + prefix-list combination

Example:

```cisco
ip prefix-list DEST seq 5 permit 203.0.113.0/24

route-map POLICY permit 10
 match ip address prefix-list DEST
 set local-preference 250

router bgp 65001
 neighbor 10.0.14.2 route-map POLICY in
```

This demonstrates:

```text
Prefix-list = WHAT route?
Route-map   = WHAT ACTION?
BGP neighbor = WHERE and WHEN?
```

---

## 9. Useful policy inspection

```cisco
show ip prefix-list
show ip prefix-list detail
show route-map
show ip bgp neighbors
```

---

## 10. BGP table interpretation

Example:

```text
*> 203.0.113.0/24  10.0.13.2  50  100  0  65010 65100 i
*  203.0.113.0/24  10.0.14.2 100  100  0  65020 65100 i
```

`*>` means:
- `*` = valid
- `>` = best path

Do not confuse:
- `Metric` = MED
- `LocPrf` = Local Preference
- `Weight` = Cisco local attribute
- `Path` = AS_PATH followed by ORIGIN code
