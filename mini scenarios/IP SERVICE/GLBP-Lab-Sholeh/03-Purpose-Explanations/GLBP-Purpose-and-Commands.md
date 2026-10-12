# GLBP Lab — Purpose and Command Explanations

**Author: Sholeh**

## 1. What is GLBP?

GLBP means **Gateway Load Balancing Protocol**. It is a Cisco first-hop redundancy protocol. It provides a shared virtual default-gateway IP address and can distribute hosts' traffic across multiple routers, rather than leaving one router as the only forwarding gateway during normal operation.

In this lab, both PCs use `192.168.10.1` as their default gateway. R1 and R2 share that virtual IP in GLBP group 10. The physical interface addresses (`192.168.10.2` and `192.168.10.3`) identify the real routers; PCs should use the virtual address (`192.168.10.1`).

## 2. GLBP roles in this topology

- **AVG — Active Virtual Gateway:** Responds to ARP requests for the virtual gateway IP and assigns a virtual MAC address to a host. R1 is preferred because it has the higher configured GLBP priority.
- **AVF — Active Virtual Forwarder:** A router that forwards packets for a GLBP virtual MAC address assigned by the AVG. With both routers healthy, R1 and R2 can each forward some hosts' traffic.
- **Backup virtual gateway:** A participating router that can take over the AVG role when the current AVG fails. R2 can assume this role if R1 becomes unavailable.
- **Virtual IP:** `192.168.10.1`, configured as the PCs' default gateway.
- **Virtual MAC:** A GLBP-created MAC address used by hosts to send frames to the assigned forwarder. The exact values depend on the device/platform and group/forwarder state; do not hard-code an expected MAC in your notes.

## 3. Key configuration commands

| Command | Purpose |
|---|---|
| `glbp 10 ip 192.168.10.1` | Enables GLBP group 10 on the interface and defines the shared virtual IP. |
| `glbp 10 priority 120` | Gives R1 a higher gateway priority than R2's 100, so R1 is preferred to become AVG. |
| `glbp 10 preempt` | Allows a higher-priority router to reclaim the AVG role after it returns, subject to platform behavior and timers. |
| `glbp 10 load-balancing round-robin` | Tells the AVG to rotate through available virtual forwarders when replying to host ARP requests. |
| `ip route 203.0.113.1 255.255.255.255 10.0.12.2` | Gives R1 a route to the lab's simulated external destination via R3. R2 has the equivalent route through its own R3 link. |
| `ip route 192.168.10.0 255.255.255.0 10.0.12.1` plus the matching route via `10.0.23.1` | Gives R3 equal-cost return paths through R1 and R2, so either path can be used while both upstream links are available. |

## 4. Why is the same GLBP configuration used on both routers?

Both routers must participate in the same group on interfaces connected to the same Layer 2 LAN. Their GLBP group number and virtual IP must match. Router-specific settings, such as physical interface IP and priority, are allowed to differ. R1 uses priority 120; R2 uses 100.

## 5. What round-robin load balancing does — and does not do

Round-robin distributes **ARP replies / virtual-forwarder assignments** across available forwarders. It does not guarantee that every individual packet is alternated between routers. A host generally keeps the virtual MAC it learned in its ARP cache until the entry expires or is cleared. For this reason, two hosts may receive different assignments, but the exact result depends on ARP timing and cache state.

## 6. Important lab boundaries

- Both GLBP router LAN interfaces must connect to the **same Layer 2 broadcast domain** (here, SW1's user LAN).
- The sample interface names are `GigabitEthernet0/0` and `GigabitEthernet0/1`. Adapt them to the interface names available on your IOS/IOS XE image.
- Use a router image/platform that supports GLBP. Some virtual router images or network simulators may not implement the feature. You can check support by entering interface configuration mode and typing `glbp ?`.
- This starter lab does not configure upstream-interface tracking. If a router's WAN link fails while its LAN interface remains up, GLBP may still assign traffic to that router. Upstream tracking/weighting is an enhancement for a later lab.
- The `203.0.113.1` loopback is a documentation/test destination inside this lab, not a real Internet service.

## 7. Useful official reference

Cisco, *First Hop Redundancy Protocols Configuration Guide — Configuring GLBP* (IOS XE):
https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipapp_fhrp/configuration/xe-16/fhp-xe-16-book/fhp-glbp.html

The command syntax and verification workflow can vary slightly by IOS/IOS XE release and hardware platform. Consult the guide for the exact platform used in your lab.
