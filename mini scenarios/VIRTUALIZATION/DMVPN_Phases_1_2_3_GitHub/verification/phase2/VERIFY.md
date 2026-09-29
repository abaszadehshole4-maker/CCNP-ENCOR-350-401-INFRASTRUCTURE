# Phase2 verification

## Commands

```text
show dmvpn
show ip nhrp
show ip eigrp neighbors
show ip route eigrp
traceroute 3.3.3.3 source loopback 0
show ip route eigrp | include 3.3.3.3
```

## Expected focus

- DMVPN tunnel/NHRP state is operational.
- EIGRP neighbors are established.
- Remote loopback routes are present.
