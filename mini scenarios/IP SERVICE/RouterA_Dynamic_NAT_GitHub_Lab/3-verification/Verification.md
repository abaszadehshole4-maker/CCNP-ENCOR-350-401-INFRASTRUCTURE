# Verification checklist

Run these commands on RouterA after applying the configuration.

## 1. Check interface status and addresses
```text
show ip interface brief
show running-config interface GigabitEthernet0/0
show running-config interface GigabitEthernet0/1
```
Expected: both interfaces should be up/up once their links are connected and the peer devices are active. G0/1 should have `10.1.1.1`.

## 2. Check ACL 1
```text
show access-lists 1
```
Expected entry:
```text
access-list 1 permit 10.1.1.0 0.0.0.63
```

## 3. Check the NAT pool and rule
```text
show running-config | include ip nat
show ip nat statistics
```
Expected: pool `exsim`, start `192.168.1.101`, end `192.168.1.164`, and a dynamic mapping that uses ACL 1 and pool `exsim`.

## 4. Generate traffic
From a host in `10.1.1.0/26`, generate traffic to a reachable destination beyond RouterA. Ensure the host uses RouterA's inside address (for example, `10.1.1.1`) as its default gateway. The ISP side must have suitable routing for the test to work end-to-end.

## 5. Inspect translations
```text
show ip nat translations
show ip nat statistics
```
Expected: translations appear after matching traffic passes through RouterA. If no translations appear, confirm traffic is routed through RouterA, ACL 1 matches the source, interfaces have correct inside/outside roles, and the NAT rule is present.

## Important
Dynamic NAT is not PAT: each active inside source needs its own pool address. The pool can run out if more simultaneous translations are needed than available pool addresses. This task does not configure a default route or ISP return routing because those details were not supplied.
