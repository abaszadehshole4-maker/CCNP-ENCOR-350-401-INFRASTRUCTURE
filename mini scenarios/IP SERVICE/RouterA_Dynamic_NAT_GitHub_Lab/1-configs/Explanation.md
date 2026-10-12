# Configuration notes

- `hostname RouterA` gives the router the scenario name.
- `GigabitEthernet0/0` is the ISP-facing interface, so it is marked `ip nat outside`.
- `GigabitEthernet0/1` is the inside interface and is assigned `10.1.1.1/26`, so it is marked `ip nat inside`.
- Standard ACL 1 matches the inside subnet: `10.1.1.0/26`. The wildcard mask `0.0.0.63` corresponds to subnet mask `255.255.255.192`.
- NAT pool `exsim` starts at `192.168.1.101` and ends at `192.168.1.164`, giving 64 addresses, with netmask `255.255.255.0`.
- `ip nat inside source list 1 pool exsim` translates matching inside source addresses to addresses from the pool.

**Address-count note:** A `/26` contains 64 total addresses, of which 62 are normally assignable host addresses because the network and broadcast addresses are reserved. The 64-address pool therefore provides at least one unique pool address for every usable inside host. The pool is deliberately sized to 64 addresses to satisfy the “large enough for each inside IP” requirement.

**Lab assumption:** The task does not specify ISP addressing, a default route, or an ISP-side return route. Those must be added separately in a complete end-to-end lab. No login password is required for the NAT configuration task, so this config does not invent credentials.
