# Source notes

The supplied document is a Phase 2 DMVPN + EIGRP lesson. Its documented lab uses:
- Hub tunnel 172.16.123.1/24
- Spoke1 tunnel 172.16.123.2/24
- Spoke2 tunnel 172.16.123.3/24
- NBMA 192.168.123.1/24, .2/24, .3/24
- EIGRP AS 123
- `no ip split-horizon eigrp 123`
- `no ip next-hop-self eigrp 123`

The Phase 1 and Phase 3 folders are structured extensions for practice. They should be validated against the exact Cisco IOS image used in EVE-NG because command support and behavior can differ between images.
