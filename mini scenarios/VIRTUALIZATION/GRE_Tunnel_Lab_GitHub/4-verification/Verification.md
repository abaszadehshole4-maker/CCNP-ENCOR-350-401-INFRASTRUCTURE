# Verification Checklist

## RouterA

```cisco
show ip interface brief
show running-config interface Tunnel1
show interfaces Tunnel1
show ip route 192.168.2.0
ping 192.168.100.2
ping 192.168.2.2
```

Expected key result:

```text
Tunnel1 is up, line protocol is up
```

## RouterB

```cisco
show ip interface brief
show running-config interface Tunnel1
show interfaces Tunnel1
show ip route 192.168.1.0
ping 192.168.100.1
ping 192.168.1.2
```

## Host-to-Host Test

From Host1:

```text
ping 192.168.2.2
```

From Host2:

```text
ping 192.168.1.2
```

## Troubleshooting Order

1. Check G0/0 and G0/1 status.
2. Check reachability of the remote GRE destination.
3. Check Tunnel1 status.
4. Check tunnel IP connectivity.
5. Check static routes.
6. Test the remote LAN host.

## GRE Packet Capture

If using EVE-NG/Wireshark, capture on the underlay link and generate traffic with:

```text
ping 192.168.2.2
```

A GRE packet uses IP protocol number **47**.

Useful Wireshark display filter:

```text
gre
```

You can also inspect the outer IP addresses to confirm that the GRE packet travels between the physical tunnel endpoints.
