# Lab Tasks

1. Configure IPv6 addressing on all router interfaces according to the addressing plan.
2. Enable IPv6 unicast routing on all routers.
3. Configure OSPFv3 process 10 and unique router IDs.
4. Place the R1–R2 and R2–R3 links in Area 0.
5. Configure R3 as the ABR by placing its R3–R6 interface in Area 1 while its other OSPF interfaces remain in Area 0.
6. Configure the VPC4 and VPC5 IPv6 addresses and default gateways.
7. Verify OSPFv3 neighbors on R1, R2, R3, and R6.
8. Verify OSPF-learned and inter-area routes.
9. Test IPv6 connectivity between VPC4 and VPC5.
10. Capture OSPFv3 Hello packets and ICMPv6 traffic in Wireshark.

## Questions for your lab notes
- Why is R3 an ABR?
- What is the difference between an intra-area and an inter-area OSPF route?
- Why must each OSPF router have a unique router ID?
- What does `ipv6 unicast-routing` enable?
- Which command confirms OSPFv3 neighbor relationships?
