# Command-by-command explanation

## Prefix list

`ip prefix-list EIGRP-TO-OSPF seq 5 permit 10.10.10.0/24` permits that exact prefix. Because there is no `le` or `ge` modifier, the entry matches the specified prefix length `/24` exactly.

`seq 10` is evaluated after `seq 5`; lower sequence numbers are checked first. The prefix `10.10.99.0/24` has no permit entry, so it matches the implicit deny at the end of the prefix list.

## Route map

`route-map EIGRP-TO-OSPF permit 10` creates a permitted route-map sequence.

`match ip address prefix-list EIGRP-TO-OSPF` makes that sequence match only routes permitted by the named prefix list. Routes that do not match any permit sequence in this route map are not redistributed by this policy.

## Redistribution command

`redistribute eigrp 100 subnets route-map EIGRP-TO-OSPF`

- `redistribute`: imports routes from another routing protocol into the current protocol.
- `eigrp 100`: identifies the source EIGRP autonomous-system number.
- `subnets`: includes classless subnet routes (important for prefixes such as /24).
- `route-map EIGRP-TO-OSPF`: applies the filtering policy to candidate routes.

The command sits under `router ospf 10` on R2 because OSPF is the destination protocol.

## OSPF external route types

When an EIGRP route is redistributed into OSPF, it is an external route. By default this is normally type 2 (`O E2`), where the external metric is considered without adding the internal OSPF path cost in the same way as E1. Type 1 (`O E1`) adds the internal OSPF cost to the external metric. This lab's default config uses the default E2 behavior.
