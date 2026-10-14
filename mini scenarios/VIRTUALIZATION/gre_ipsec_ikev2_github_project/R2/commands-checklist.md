# R2 command checklist

Run these in privileged EXEC mode unless noted:

```text
show ip interface brief
show ip route
ping 203.0.113.1
show crypto ikev2 sa
show crypto ipsec sa
show interfaces Tunnel0
show ip ospf neighbor
show ip route ospf
show ip protocols
```

To validate the return path, run tests from the R2 side as well as R1. Confirm the IPsec counters increase in both directions after generating traffic. The command syntax/output can vary by IOS/IOS XE image.
