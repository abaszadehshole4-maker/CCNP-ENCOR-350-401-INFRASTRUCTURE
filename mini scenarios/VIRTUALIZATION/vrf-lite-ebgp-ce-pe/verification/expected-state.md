# Expected Final State

## PE-SW

BLUE:
- CE neighbor `172.31.100.2`, AS `65101`
- Learned `192.0.2.10/32` and `192.168.10.0/24`

GREEN:
- CE neighbor `172.31.200.2`, AS `65102`
- Learned `192.0.2.20/32` and `192.168.20.0/24`

Both eBGP sessions should be `Established`.

## Isolation proof

`192.0.2.10/32` belongs to BLUE, not GREEN.

`192.0.2.20/32` belongs to GREEN, not BLUE.

Use:

```text
show ip route vrf BLUE
show ip route vrf GREEN
```
