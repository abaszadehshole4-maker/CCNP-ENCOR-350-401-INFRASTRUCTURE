# MST concepts and interview notes

## What is MST?

Multiple Spanning Tree Protocol (MST, IEEE 802.1s and incorporated into 802.1Q) allows VLANs to be mapped to a smaller number of spanning-tree instances. Each instance calculates a loop-free topology; multiple VLANs may share one instance to reduce per-VLAN spanning-tree overhead.

## Core concepts

- **MST region:** Switches that share the same region name, revision, and VLAN-to-instance mapping.
- **MST instance (MSTI):** A spanning-tree topology for a mapped group of VLANs.
- **CIST / IST:** The Common and Internal Spanning Tree provide the common spanning-tree connectivity across regions and the internal region tree.
- **Root bridge:** The bridge with the lowest bridge ID for an instance. Lower configurable priority is preferred; MAC address breaks ties.
- **Port roles:** Root, designated, alternate (and other roles depending on view/platform).
- **Port states:** Forwarding or discarding in MST operation; classic show output may label roles/states using platform-specific terms.
- **Region mismatch:** A mismatch means switches may behave as separate regions even if they are physically connected.
- **Edge/PortFast:** Use only for end-device-facing access ports, never indiscriminately on switch-to-switch trunks.

## Why use two instances?

In this lab, instance 1 prefers SW1 as root for VLANs 10 and 20. Instance 2 prefers SW2 as root for VLANs 30 and 40. This demonstrates load distribution at the spanning-tree topology level while preserving loop-free forwarding per instance.

## MST vs per-VLAN STP

Traditional PVST+/Rapid PVST+ commonly maintains an instance per VLAN. MST allows many VLANs to share an instance, which can reduce control-plane overhead in environments with many VLANs.

## Interview questions

1. What three parameters must match for devices to belong to the same MST region?
2. Why can two switches with the same MST name still be in different regions?
3. How does a lower bridge priority affect root selection?
4. Why map multiple VLANs to one MST instance?
5. What is an alternate port, and when can it forward?
6. What symptoms can a region mismatch cause?
7. Why should PortFast be limited to end-device ports?
8. How would you verify that SW1 is root for instance 1 and SW2 is root for instance 2?
