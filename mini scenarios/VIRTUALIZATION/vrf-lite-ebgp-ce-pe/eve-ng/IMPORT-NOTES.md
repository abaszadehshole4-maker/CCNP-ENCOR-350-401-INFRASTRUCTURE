# EVE-NG Import Notes

The lab uses generic `vios`, `viosl2`, and `vpcs` image identifiers. Map these to the images installed on your EVE-NG server.

Files:
- `vrf-lite-ebgp-ce-pe-starter.unl` — guided lab starting point.
- `vrf-lite-ebgp-ce-pe-solved.unl` — final configuration state.

VPCS setup:

```text
PC-A> ip 192.168.10.10/24 192.168.10.1
PC-A> save
PC-B> ip 192.168.20.10/24 192.168.20.1
PC-B> save
```
