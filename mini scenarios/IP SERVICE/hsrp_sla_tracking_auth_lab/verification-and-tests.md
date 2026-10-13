# Verification and Test Plan

## 1. Baseline: R1 should be Active

On both routers:

```text
show standby brief
show standby GigabitEthernet0/0
show ip sla statistics
show track 10
show ip route 203.0.113.1
```

Expected baseline:
- R1 group 10: **Active**, priority 110.
- R2 group 10: **Standby**, priority 100.
- R1 track 10: **Up**.
- R1 IP SLA operation: successful ICMP replies.
- Client can ping `192.168.10.1` and `203.0.113.1`.

Depending on the IOS version, the `show standby` output layout differs.

## 2. Test object tracking and failover

Goal: make R1 unable to reach the SLA target while keeping the LAN interface up.

One safe lab method is to apply a temporary ACL on ISP G0/0 that denies ICMP echo from R1's WAN address to the loopback, while permitting other traffic. Syntax and ACL attachment direction depend on your platform. Alternatively, shut ISP G0/0 in the isolated lab, understanding that this also removes R1's WAN next hop.

After the failure:
1. Wait for the SLA timeout and track state change.
2. On R1, run `show ip sla statistics` and `show track 10`.
3. Run `show standby brief` on R1 and R2.
4. Confirm R1's effective HSRP priority falls from 110 to 80 (110 minus 30), and R2 becomes Active at priority 100.
5. Ping the virtual IP continuously from the client to observe interruption and recovery.

## 3. Restore the path

Restore the ACL/interface. After SLA success resumes:
- R1 track 10 should return Up.
- R1 priority returns to 110.
- Because R1 has `preempt`, R1 should take Active status again after HSRP detects the higher priority. A brief transition is normal.

## 4. Authentication validation

Both routers must use the same HSRP group and authentication settings. With matching settings, the group should form normally.

In an isolated lab only, change the authentication key on R2 temporarily. Observe HSRP adjacency/peer behavior and system logs, then restore the matching key. Exact error messages and behavior vary by IOS release. Do not perform this test on a production VLAN.

## 5. Troubleshooting checklist

- Confirm both LAN interfaces are in the same Layer 2 VLAN and subnet.
- Confirm both use HSRP version 2 and group 10.
- Confirm virtual IP is not assigned to a physical interface or another host.
- Confirm authentication settings match.
- Confirm R1 can reach `203.0.113.1` using its configured source interface.
- Check `show ip sla configuration`, `show ip sla statistics`, and `show track 10`.
- Ensure the decrement is large enough: R1's 110 - 30 = 80, below R2's 100.
- Check that preemption is enabled on the router expected to reclaim Active status.
- If an IOS image rejects the MD5 authentication command, verify that image's supported HSRP authentication syntax.

## Expected state table

| State | R1 track | R1 effective priority | R1 role | R2 role |
|---|---|---:|---|---|
| Normal upstream reachability | Up | 110 | Active | Standby |
| R1 SLA target unreachable | Down | 80 | Standby | Active |
| Upstream restored | Up | 110 | Active after preemption | Standby |
