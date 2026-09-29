# Verification Checklist

Run these tests in order.

## 1. Interfaces

```cisco
show ip interface brief
```

## 2. Underlay

```cisco
ping 10.0.12.2
```

from R1, and:

```cisco
ping 10.0.12.1
```

from R2.

## 3. VRF

```cisco
show vrf
show ip route vrf CUSTOMER
```

## 4. GRE

```cisco
show interface Tunnel0
show run interface Tunnel0
```

Expected:

```text
Tunnel0 is up, line protocol is up
```

## 5. Tunnel IP

```cisco
ping vrf CUSTOMER 172.16.12.2
```

from R1, and the reverse from R2.

## 6. Remote routes

R1:

```cisco
show ip route vrf CUSTOMER 192.168.20.0
```

R2:

```cisco
show ip route vrf CUSTOMER 192.168.10.0
```

## 7. End-to-end

PC1:

```text
ping 192.168.20.10
```

PC2:

```text
ping 192.168.10.10
```
