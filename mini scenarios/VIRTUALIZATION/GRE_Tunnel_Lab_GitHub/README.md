# GRE Tunnel Lab – RouterA ↔ RouterB

**Creator:** Sholeh  
**Topic:** Basic GRE tunnel with static routing  
**Platform:** Cisco IOS / EVE-NG

## 1. Lab Objective

Build a GRE tunnel between RouterA and RouterB and route the two LAN networks through the tunnel.

### Addressing

| Device | Interface | IP Address | Mask |
|---|---|---|---|
| RouterA | G0/0 | 10.10.10.2 | 255.255.255.0 |
| RouterA | G0/1 | 192.168.1.1 | 255.255.255.0 |
| RouterB | G0/0 | 10.10.20.2 | 255.255.255.0 |
| RouterB | G0/1 | 192.168.2.1 | 255.255.255.0 |
| Host1 | NIC | 192.168.1.2 | 255.255.255.0 |
| Host2 | NIC | 192.168.2.2 | 255.255.255.0 |
| RouterA | Tunnel1 | 192.168.100.1 | 255.255.255.252 |
| RouterB | Tunnel1 | 192.168.100.2 | 255.255.255.252 |

## 2. Important Topology Assumption

The assigned addressing does not explicitly show how RouterA G0/0 and RouterB G0/0 reach each other. This lab therefore assumes the **10.10.10.0/24 and 10.10.20.0/24 networks are the underlay/transit networks** and that each router has a route to the other router's physical tunnel endpoint.

For the direct two-router EVE-NG version supplied with this repository, RouterA G0/0 and RouterB G0/0 are connected through the underlay network.

> If your physical topology uses an ISP/router between RouterA and RouterB, replace the tunnel destination with the remote G0/0 IP and add the required underlay routes.

## 3. GRE Configuration

### RouterA

```cisco
interface Tunnel1
 ip address 192.168.100.1 255.255.255.252
 tunnel source GigabitEthernet0/0
 tunnel destination 10.10.20.2
 tunnel mode gre ip
 no shutdown

ip route 192.168.2.0 255.255.255.0 192.168.100.2
```

### RouterB

```cisco
interface Tunnel1
 ip address 192.168.100.2 255.255.255.252
 tunnel source GigabitEthernet0/0
 tunnel destination 10.10.10.2
 tunnel mode gre ip
 no shutdown

ip route 192.168.1.0 255.255.255.0 192.168.100.1
```

The lab specifically requires:
- Tunnel source specified as an **interface**.
- Static-route next hop specified as an **IP address**.

## 4. Host Configuration

Host1:
- IP: `192.168.1.2/24`
- Default gateway: `192.168.1.1`

Host2:
- IP: `192.168.2.2/24`
- Default gateway: `192.168.2.1`

## 5. Verification

On RouterA:

```cisco
show ip interface brief
show interfaces tunnel 1
show ip route
show ip route 192.168.2.0
ping 192.168.100.2
ping 192.168.2.2
```

On RouterB:

```cisco
show ip interface brief
show interfaces tunnel 1
show ip route
show ip route 192.168.1.0
ping 192.168.100.1
ping 192.168.1.2
```

A healthy tunnel should show:

```text
Tunnel1 is up, line protocol is up
```

## 6. Useful GRE Troubleshooting

If the tunnel is down:

1. Verify the physical interfaces:
   ```cisco
   show ip interface brief
   ```

2. Verify that each router can reach the **remote tunnel destination** through the underlay:
   ```cisco
   ping 10.10.20.2
   ```
   from RouterA, and:
   ```cisco
   ping 10.10.10.2
   ```
   from RouterB.

3. Verify the tunnel configuration:
   ```cisco
   show running-config interface Tunnel1
   ```

4. Verify the tunnel line protocol:
   ```cisco
   show interfaces Tunnel1
   ```

5. Verify the static route:
   ```cisco
   show ip route 192.168.2.0
   show ip route 192.168.1.0
   ```

## 7. Packet Flow

Host1 → RouterA G0/1 → RouterA Tunnel1 → GRE encapsulation → RouterB Tunnel1 → RouterB G0/1 → Host2.

The original LAN packet is encapsulated inside GRE while it crosses the underlay. The remote router removes the GRE encapsulation and forwards the original packet toward the destination LAN.

## 8. Portfolio Learning Points

This lab demonstrates:

- GRE tunnel interface creation
- GRE source interface configuration
- GRE destination configuration
- Tunnel addressing
- Static routing through a tunnel
- Underlay versus overlay concepts
- GRE verification and troubleshooting
