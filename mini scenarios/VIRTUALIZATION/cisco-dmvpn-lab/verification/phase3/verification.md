# Phase 3 Verification

## 1. Check configuration

Hub:

```cisco
show running-config interface tunnel 0
```

Look for:

```cisco
ip nhrp redirect
```

Spokes:

```cisco
show running-config interface tunnel 0
```

Look for:

```cisco
ip nhrp shortcut
```

## 2. Generate spoke-to-spoke traffic

From PC1:

```text
ping 10.10.20.10
```

## 3. Inspect NHRP

On R2:

```cisco
show ip nhrp
show ip nhrp detail
```

On R3:

```cisco
show ip nhrp
show ip nhrp detail
```

The goal is to observe the NHRP information associated with the optimized spoke-to-spoke path.

## 4. DMVPN

```cisco
show dmvpn
```

## 5. Routing

```cisco
show ip route 10.10.20.0
```

Phase 3 uses NHRP redirect/shortcut to optimize traffic dynamically without requiring the same EIGRP next-hop manipulation used by Phase 2.

Conceptually:

```text
Initial:     R2 → R1 → R3

Optimized:   R2 →→→ R3
```
