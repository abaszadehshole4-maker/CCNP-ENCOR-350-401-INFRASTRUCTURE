# IPv6 Addressing Plan

| Link / Segment | Device interface | IPv6 address | OSPF area |
|---|---|---|---|
| VPC4 LAN | R1 E0/1 | 2001:DB8:1:10::1/64 | 0 |
| VPC4 LAN | VPC4 E0 | 2001:DB8:1:10::10/64 | Host |
| R1–R2 | R1 E0/0 | 2001:DB8:12::1/64 | 0 |
| R1–R2 | R2 E0/0 | 2001:DB8:12::2/64 | 0 |
| R2–R3 | R2 E0/1 | 2001:DB8:23::2/64 | 0 |
| R2–R3 | R3 E0/0 | 2001:DB8:23::3/64 | 0 |
| VPC5 LAN | R3 E0/1 | 2001:DB8:3:30::1/64 | 0 |
| VPC5 LAN | VPC5 E0 | 2001:DB8:3:30::30/64 | Host |
| R3–R6 | R3 E0/2 | 2001:DB8:3:40::3/64 | 1 |
| R3–R6 | R6 E0/0 | 2001:DB8:3:40::6/64 | 1 |

**Addressing assumptions:** The diagram labels the R2–R3 link with R3's `2001:DB8:23::3/64` address, so R2 is assigned `::2/64`. The R3–R6 endpoint addresses are proposed as `::3/64` and `::6/64` because both endpoint host IDs are not clearly shown. Confirm these match your EVE-NG interface plan before pasting configurations.
