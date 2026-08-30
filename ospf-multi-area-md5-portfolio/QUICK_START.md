# Quick Start

1. Import `eve-ng/ospf-multi-area-md5.unl` into EVE-NG.
2. If necessary, replace the node image reference with the IOL L3 image installed on your server.
3. Start all four routers.
4. If the startup configuration is not automatically present, paste the matching file from `configs/` into each router.
5. Run `show ip interface brief` on every router.
6. Run `show ip ospf neighbor` and confirm three adjacencies.
7. Run `show ip ospf interface Ethernet0/0` on RouterA and RouterB to validate MD5.
8. Test reachability to remote Loopback addresses.
9. Save configurations with `copy running-config startup-config`.
