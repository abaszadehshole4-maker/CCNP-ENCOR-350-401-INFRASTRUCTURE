# Phase 1 Verification

## 1. Underlay

Run on all routers:

```cisco
show ip interface brief
ping 172.16.0.1
ping 172.16.0.2
ping 172.16.0.3
```

Expected: the required underlay addresses are reachable.

## 2. DMVPN

```cisco
show dmvpn
```

Expected:
- R1 is the hub.
- R2 and R3 are registered spokes.
- Tunnel0 is operational.

## 3. NHRP

```cisco
show ip nhrp
show ip nhrp detail
```

Expected:
- Spokes have an NHRP mapping for the hub.
- The hub has dynamic registrations from R2 and R3.

## 4. EIGRP

```cisco
show ip eigrp neighbors
show ip route eigrp
```

Expected:
- EIGRP adjacency exists over the DMVPN overlay.
- Remote branch LAN routes are present.

## 5. End-to-End

From PC1:

```text
ping 10.10.20.10
```

Phase 1 traffic is hub-centric:

```text
R2 → R1 → R3
```

Use routing/NHRP output to confirm the hub-centric behavior.
