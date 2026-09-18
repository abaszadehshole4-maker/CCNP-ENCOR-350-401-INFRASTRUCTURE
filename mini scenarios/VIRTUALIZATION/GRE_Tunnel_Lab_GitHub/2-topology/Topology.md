# EVE-NG Topology

```text
                 UNDERLAY
        10.10.10.0/24 <----> 10.10.20.0/24
              |                    |
           RouterA              RouterB
        G0/0 10.10.10.2       G0/0 10.10.20.2
              |                    |
        Tunnel1 192.168.100.1/30 -- Tunnel1 192.168.100.2/30
              |      GRE OVERLAY       |
           G0/1                    G0/1
      192.168.1.1/24          192.168.2.1/24
              |                    |
           Host1                 Host2
       192.168.1.2           192.168.2.2
```

## EVE-NG node connections

- RouterA G0/0 ↔ RouterB G0/0
- RouterA G0/1 ↔ Host1
- RouterB G0/1 ↔ Host2

If your EVE-NG lab uses an intermediate router/ISP, keep the assigned LAN addresses but modify the underlay addressing and add routes so each physical tunnel endpoint can reach the other.
