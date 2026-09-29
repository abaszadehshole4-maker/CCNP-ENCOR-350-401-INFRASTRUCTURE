# DMVPN Phase1 topology

```text
                         Underlay / NBMA
                  192.168.123.0/24

                    R1-HUB
                 192.168.123.1
                  Tunnel0
                172.16.123.1
                  /       \
                 /         \
          R2-SPOKE1       R3-SPOKE2
          .2 / .2         .3 / .3
       NBMA .2          NBMA .3

Loopbacks:
R1 = 1.1.1.1/32
R2 = 2.2.2.2/32
R3 = 3.3.3.3/32

EIGRP AS 123
```

Phase: **Phase1**

Use the configuration in `configuration/phase1/`.

