# BGP Wireshark Filter Cheat Sheet

## Display filter bar

Enter one filter and press Enter:

```wireshark
bgp
tcp.port == 179
ip.addr == 2.2.2.2 && ip.addr == 3.3.3.3 && tcp.port == 179
bgp.type == 2
tcp.flags.syn == 1
tcp.analysis.retransmission
```

## Capture filter field

Enter before starting capture:

```text
tcp port 179
```

## What these messages mean

- **OPEN**: peers begin a BGP session and announce basic capabilities/parameters, including AS information.
- **KEEPALIVE**: helps maintain the BGP session.
- **UPDATE**: advertises or withdraws network-layer reachability and includes path attributes such as AS_PATH and NEXT_HOP.
- **NOTIFICATION**: reports an error and generally closes the session.

The Weight attribute does not appear in UPDATE packets because it is Cisco-local and isn't propagated to BGP peers. Use the router's BGP table to verify it.
