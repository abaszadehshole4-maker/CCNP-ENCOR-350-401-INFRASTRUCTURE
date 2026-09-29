# Phase 2 Verification

## 1. Check EIGRP next hop

On R2:

```cisco
show ip route 10.10.20.0
```

On R3:

```cisco
show ip route 10.10.10.0
```

Expected: the remote branch route should retain the remote spoke as the routing next hop rather than the hub.

## 2. Check DMVPN/NHRP

```cisco
show dmvpn
show ip nhrp
show ip nhrp detail
```

## 3. Check EIGRP

```cisco
show ip eigrp neighbors
show ip eigrp topology
```

## 4. Generate traffic

From PC1:

```text
ping 10.10.20.10
```

From PC2:

```text
ping 10.10.10.10
```

The intended forwarding path is direct spoke-to-spoke:

```text
R2 → R3
```

instead of:

```text
R2 → R1 → R3
```

## 5. Important Phase 2 commands on the hub

```cisco
interface Tunnel0
 no ip split-horizon eigrp 100
 no ip next-hop-self eigrp 100
```

These allow the hub to advertise routes learned from one spoke to another while preserving the original EIGRP next hop.
