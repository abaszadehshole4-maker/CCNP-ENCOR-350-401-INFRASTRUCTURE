# BGP Path Selection & Route Filtering Lab

**Creator:** Sholeh  
**Platform:** EVE-NG / Cisco IOSv (or compatible Cisco IOS image)  
**Topic:** BGP path selection, inbound policy, route filtering, MED, and troubleshooting


## 0.1 EVE-NG import notes

The included `topology/bgp-path-selection.unl` is built for a **Cisco IOSv** template and references a common IOSv image name:

```text
vios-adventerprisek9-m.vmdk.SPA.156-2.T
```

If your EVE-NG installation uses another IOSv image name, change the `image=` value in the `.unl` file to match your installed image. The logical topology, interfaces, AS numbers and IP addressing remain unchanged.

After importing the `.unl` file:

1. Start all six routers.
2. Open each console.
3. Paste the corresponding file from `configs/`.
4. Wait for BGP convergence.
5. Follow `verification/experiments.md` from Experiment 0 through Experiment 7.

The `.unl` file provides the **portable topology**; the router configurations are intentionally kept as separate text files so the repository is easy to read, review and reuse on GitHub.

## 1. Lab objectives

This portfolio lab demonstrates, step by step:

- eBGP and iBGP
- BGP route advertisement
- Weight
- Local Preference
- Locally originated routes
- AS_PATH length
- ORIGIN (I / E / ?)
- MED
- `bgp always-compare-med`
- Prefix-list filtering
- Route-maps
- Inbound vs outbound filtering
- BGP soft reset / route refresh
- Verification and troubleshooting

The lab intentionally advertises the **same destination prefix `203.0.113.0/24` through three ISP paths** so that the BGP decision process can be observed and changed one attribute at a time.

---

## 2. Topology

```text
                         AS 65100
                           R6
                    Destination / Origin
                    10.0.36.2/30
                    10.0.46.2/30
                    10.0.56.2/30
                      /    |    \
                     /     |     \
             AS65010 R3    R4 AS65020    R5 AS65030
                    ISP1    ISP2           ISP3
                      |        |             |
                  10.0.13.2 10.0.14.2   10.0.25.2
                      |        |             |
                      +---- R1 +-------------+
                           \ 
                            \  iBGP
                             \
                              R2
                           AS 65001

R1: 1.1.1.1/32
R2: 2.2.2.2/32
R3: 3.3.3.3/32
R4: 4.4.4.4/32
R5: 5.5.5.5/32
R6: 6.6.6.6/32
Destination: 203.0.113.0/24
```

### Links

| Link | Subnet | Side A | Side B |
|---|---|---|---|
| R1-R2 | 10.0.12.0/30 | R1 .1 | R2 .2 |
| R1-R3 | 10.0.13.0/30 | R1 .1 | R3 .2 |
| R1-R4 | 10.0.14.0/30 | R1 .1 | R4 .2 |
| R2-R5 | 10.0.25.0/30 | R2 .1 | R5 .2 |
| R3-R6 | 10.0.36.0/30 | R3 .1 | R6 .2 |
| R4-R6 | 10.0.46.0/30 | R4 .1 | R6 .2 |
| R5-R6 | 10.0.56.0/30 | R5 .1 | R6 .2 |

---

## 3. BGP AS design

| Router | Role | AS |
|---|---|---:|
| R1 | Customer edge | 65001 |
| R2 | Customer edge / iBGP peer | 65001 |
| R3 | ISP-1 | 65010 |
| R4 | ISP-2 | 65020 |
| R5 | ISP-3 | 65030 |
| R6 | Destination/origin AS | 65100 |

R1 learns paths through R3 and R4.  
R2 learns a path through R5 and sends it to R1 over iBGP.

---

# 4. Important BGP path-selection order

For this Cisco lab, the important order is:

1. **Weight** — highest wins; Cisco-specific and local to one router.
2. **Local Preference** — highest wins; normally propagated throughout the local AS.
3. **Locally originated** route.
4. **Shortest AS_PATH**.
5. **Lowest ORIGIN**: IGP (`i`) < EGP (`e`) < Incomplete (`?`).
6. **Lowest MED**.
7. eBGP over iBGP.
8. Lowest IGP metric to the BGP next hop.
9. Oldest path (where applicable).
10. Lowest BGP router ID / tie-breakers.

The exact later tie-break sequence can vary with Cisco IOS features and BGP configuration, but the first six attributes are the focus of this lab.

---

# 5. Addressing and base configuration

All routers use their loopback as BGP router ID.

> If your EVE-NG image uses different interface names, replace `GigabitEthernet0/x` with the correct names.

## Step 1 — Start the lab

Import the `.unl` file from `topology/` into EVE-NG and connect to each router console.

Apply the configuration files in:

```text
configs/
```

Then verify basic IP connectivity before troubleshooting BGP.

---

# 6. Step 2 — Build eBGP and iBGP

### Customer AS 65001

R1 peers with R2 using loopbacks:

```cisco
router bgp 65001
 bgp router-id 1.1.1.1
 neighbor 2.2.2.2 remote-as 65001
 neighbor 2.2.2.2 update-source Loopback0
 neighbor 2.2.2.2 next-hop-self
 neighbor 10.0.13.2 remote-as 65010
 neighbor 10.0.14.2 remote-as 65020
```

R2:

```cisco
router bgp 65001
 bgp router-id 2.2.2.2
 neighbor 1.1.1.1 remote-as 65001
 neighbor 1.1.1.1 update-source Loopback0
 neighbor 1.1.1.1 next-hop-self
 neighbor 10.0.25.2 remote-as 65030
```

### Why `next-hop-self`?

When R1 learns a route from R3, R1 can advertise it to R2 with itself as the next hop. This makes iBGP forwarding easier to understand in a lab.

---

# 7. Step 3 — Verify neighbors

Run:

```cisco
show ip bgp summary
show ip bgp neighbors
```

Expected state:

```text
Established
```

If not Established, check:

```cisco
show ip interface brief
show ip route
ping <neighbor-ip>
show ip bgp summary
show ip bgp neighbors <neighbor-ip>
```

---

# 8. Step 4 — Advertise 203.0.113.0/24

R6 originates the destination:

```cisco
interface Loopback100
 ip address 203.0.113.1 255.255.255.0

router bgp 65100
 bgp router-id 6.6.6.6
 network 203.0.113.0 mask 255.255.255.0
```

R6 advertises the prefix to R3, R4 and R5.

ISP routers advertise the prefix toward the customer.

---

# 9. Step 5 — Baseline verification

On R1:

```cisco
show ip bgp
show ip bgp 203.0.113.0
show ip route 203.0.113.0
```

The important fields are:

```text
Network
Next Hop
Metric
LocPrf
Weight
Path
```

Example interpretation:

```text
*> 203.0.113.0/24  10.0.13.2  100  0  65010 65100 i
```

Meaning:

- `*` = valid BGP path
- `>` = selected best path
- Next hop = 10.0.13.2
- Local Preference = 100
- Weight = 0
- AS_PATH = `65010 65100`
- Origin = `i`

---

# 10. Experiment 1 — WEIGHT

Weight is local to the router.

On R1, prefer ISP1:

```cisco
ip prefix-list DEST permit 203.0.113.0/24

route-map ISP1-WEIGHT permit 10
 match ip address prefix-list DEST
 set weight 500

router bgp 65001
 neighbor 10.0.13.2 route-map ISP1-WEIGHT in
```

Verify:

```cisco
show ip bgp 203.0.113.0
```

R1 should prefer the ISP1 path because:

```text
Weight 500 > Weight 0
```

### Important lesson

Weight affects only the local router. It is **not advertised to other BGP routers**.

---

# 11. Experiment 2 — LOCAL PREFERENCE

Remove the weight policy:

```cisco
router bgp 65001
 no neighbor 10.0.13.2 route-map ISP1-WEIGHT in
```

Configure:

```cisco
route-map ISP2-LOCALPREF permit 10
 match ip address prefix-list DEST
 set local-preference 200

router bgp 65001
 neighbor 10.0.14.2 route-map ISP2-LOCALPREF in
```

Verify:

```cisco
show ip bgp 203.0.113.0
```

Now the ISP2 path should win because:

```text
Local Preference 200 > 100
```

### Important lesson

Local Preference is an AS-wide policy attribute. It is normally used to tell your own AS which exit path should be preferred.

---

# 12. Experiment 3 — AS_PATH

Remove the local-preference policy:

```cisco
router bgp 65001
 no neighbor 10.0.14.2 route-map ISP2-LOCALPREF in
```

Now make ISP1 artificially prepend its AS:

```cisco
route-map ISP1-PREPEND permit 10
 match ip address prefix-list DEST
 set as-path prepend 65010 65010 65010

router bgp 65010
 neighbor 10.0.13.1 route-map ISP1-PREPEND out
```

ISP1 path becomes approximately:

```text
65010 65010 65010 65010 65100
```

while ISP2 might be:

```text
65020 65100
```

The shorter AS_PATH wins.

Verify on R1:

```cisco
show ip bgp 203.0.113.0
```

### Important lesson

AS_PATH is used to avoid loops and influence path preference. In this experiment, the artificially longer path loses.

---

# 13. Experiment 4 — ORIGIN

ORIGIN preference:

```text
IGP (i)     best
EGP (e)
Incomplete (?) worst
```

We will deliberately change the BGP origin attribute.

On ISP2:

```cisco
route-map SET-EGP permit 10
 match ip address prefix-list DEST
 set origin egp

router bgp 65020
 neighbor 10.0.14.1 route-map SET-EGP out
```

On ISP3:

```cisco
route-map SET-INCOMPLETE permit 10
 match ip address prefix-list DEST
 set origin incomplete

router bgp 65030
 neighbor 10.0.25.1 route-map SET-INCOMPLETE out
```

The ISP1 path remains IGP-origin (`i`).

Verify:

```cisco
show ip bgp 203.0.113.0
```

If higher-priority attributes are equal, the path with:

```text
i
```

wins over:

```text
e
```

and:

```text
?
```

---

# 14. Experiment 5 — MED

MED means Multi-Exit Discriminator.

Lower is better.

For example:

```text
ISP1 MED = 50
ISP2 MED = 100
```

ISP1 is preferred if MED is the deciding attribute.

Configure:

```cisco
route-map ISP1-MED permit 10
 match ip address prefix-list DEST
 set metric 50

route-map ISP2-MED permit 10
 match ip address prefix-list DEST
 set metric 100
```

Apply outbound:

```cisco
router bgp 65010
 neighbor 10.0.13.1 route-map ISP1-MED out

router bgp 65020
 neighbor 10.0.14.1 route-map ISP2-MED out
```

### Cisco MED comparison note

By default, MED is normally compared between paths learned from the same neighboring AS.

For this lab, enable:

```cisco
router bgp 65001
 bgp always-compare-med
```

This deliberately allows the lab to compare MED between different neighboring ASes.

Verify:

```cisco
show ip bgp 203.0.113.0
```

Lower MED wins, assuming all higher-priority attributes are equal.

---

# 15. Experiment 6 — Route filtering with prefix-lists

A very important real-world skill is controlling which routes are accepted or advertised.

## Inbound filtering

Example: allow only `203.0.113.0/24` from ISP1.

```cisco
ip prefix-list ISP1-IN seq 5 permit 203.0.113.0/24

router bgp 65001
 neighbor 10.0.13.2 prefix-list ISP1-IN in
```

Verify:

```cisco
show ip bgp
show ip bgp neighbors 10.0.13.2 received-routes
```

Depending on IOS version, `received-routes` may require inbound soft-reconfiguration. Prefer route-refresh where supported.

## Outbound filtering

Allow only the customer prefix:

```cisco
ip prefix-list CUSTOMER-OUT seq 5 permit 203.0.113.0/24

router bgp 65001
 neighbor 10.0.13.2 prefix-list CUSTOMER-OUT out
```

### Filtering principle

```text
prefix-list
     ↓
route-map (optional)
     ↓
BGP neighbor
     ↓
in / out
```

---

# 16. Prefix-list logic

Examples:

```cisco
ip prefix-list TEST seq 5 permit 203.0.113.0/24
```

Matches exactly `/24`.

To permit the `/24` and more-specifics:

```cisco
ip prefix-list TEST seq 5 permit 203.0.113.0/24 le 32
```

To permit a range:

```cisco
ip prefix-list TEST seq 5 permit 203.0.113.0/24 ge 25 le 28
```

Remember:

- `ge` = greater than or equal to prefix length
- `le` = less than or equal to prefix length

---

# 17. Step 7 — Soft reset / policy changes

After changing an inbound policy:

```cisco
clear ip bgp 10.0.13.2 soft in
```

Outbound:

```cisco
clear ip bgp 10.0.13.2 soft out
```

Modern Cisco IOS can often use route refresh without resetting the BGP TCP session.

Verify:

```cisco
show ip bgp summary
```

The neighbor should remain Established.

---

# 18. Troubleshooting workflow

## Check interfaces

```cisco
show ip interface brief
```

## Check IP reachability

```cisco
ping 10.0.13.2
ping 10.0.14.2
ping 2.2.2.2
```

## Check routing table

```cisco
show ip route
show ip route 203.0.113.0
```

## Check BGP neighbors

```cisco
show ip bgp summary
show ip bgp neighbors
```

## Check one destination

```cisco
show ip bgp 203.0.113.0
```

## Check advertised routes

```cisco
show ip bgp neighbors 10.0.13.2 advertised-routes
```

## Check received routes

```cisco
show ip bgp neighbors 10.0.13.2 received-routes
```

If unsupported or requiring extra configuration:

```cisco
show ip bgp neighbors 10.0.13.2 routes
```

## Check policy

```cisco
show ip prefix-list
show route-map
show ip bgp neighbors 10.0.13.2
```

## Check BGP table

```cisco
show ip bgp
```

---

# 19. Debugging

Use carefully in a lab:

```cisco
debug ip bgp
debug ip bgp updates
debug ip bgp events
```

Stop debugging:

```cisco
undebug all
```

or:

```cisco
u all
```

---

# 20. Common problems

### BGP stuck in Idle/Active

Check:

```cisco
ping <neighbor>
show ip route <neighbor>
show ip bgp summary
show ip bgp neighbors <neighbor>
```

Typical causes:

- wrong neighbor IP
- wrong remote AS
- interface down
- missing route to neighbor
- ACL/firewall issue
- update-source mismatch
- TTL issue for multihop sessions

### Route exists in BGP but not routing table

Check:

```cisco
show ip bgp 203.0.113.0
show ip route 203.0.113.0
```

BGP may have the route but another route may be preferred, or the BGP next hop may be unreachable.

### Route is missing

Check:

```cisco
show ip bgp neighbors <neighbor> received-routes
show ip bgp neighbors <neighbor> routes
show ip bgp neighbors <neighbor> advertised-routes
show ip prefix-list
show route-map
```

### Policy changed but route did not change

Use:

```cisco
clear ip bgp <neighbor> soft in
```

or:

```cisco
clear ip bgp <neighbor> soft out
```

---

# 21. Portfolio evidence

For a GitHub portfolio, capture screenshots of:

1. `show ip bgp summary`
2. `show ip bgp 203.0.113.0`
3. Weight winning
4. Local Preference winning
5. AS_PATH winning
6. ORIGIN comparison
7. MED comparison
8. Prefix-list filtering
9. `show ip bgp neighbors ... advertised-routes`
10. `show ip bgp neighbors ... received-routes`

A good screenshot should show the selected route with `*>`.

---

# 22. Recommended experiment order

Run the experiments in this order and remove the previous policy before starting the next:

```text
Baseline
   ↓
Weight
   ↓
Local Preference
   ↓
AS_PATH
   ↓
ORIGIN
   ↓
MED
   ↓
Route Filtering
   ↓
Troubleshooting
```

The key learning point is:

> **BGP does not simply choose the shortest physical path. It evaluates BGP attributes and policy.**

---

# 23. Files in this repository

```text
BGP_Path_Selection_Portfolio/
├── README.md
├── configs/
│   ├── R1.txt
│   ├── R2.txt
│   ├── R3.txt
│   ├── R4.txt
│   ├── R5.txt
│   └── R6.txt
├── topology/
│   ├── bgp-path-selection.unl
│   └── topology.dot
└── verification/
    ├── verification-commands.txt
    └── troubleshooting.txt
```

---

# 24. Author

**Created by Sholeh**

This lab was built as a practical Cisco BGP portfolio project demonstrating route selection, policy control, filtering, verification, and troubleshooting in EVE-NG.
