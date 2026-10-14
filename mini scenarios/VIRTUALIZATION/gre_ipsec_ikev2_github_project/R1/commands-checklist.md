# R1 command checklist

Run these in privileged EXEC mode unless noted:

```text
show ip interface brief
show ip route
ping 203.0.113.2
show crypto ikev2 sa
show crypto ipsec sa
show interfaces Tunnel0
show ip ospf neighbor
show ip route ospf
show ip protocols
```

To check the IPsec counters, record `show crypto ipsec sa`, generate traffic across the tunnel, then run it again. The encapsulation/encryption and decapsulation/decryption counters should increase when matching traffic traverses the link. Exact field names differ by release.

If applying the config manually, enter configuration mode with `configure terminal`, paste the relevant sections, then use `end` and `write memory` after checking the result. Do not paste the `end` line in the middle of configuration mode.
