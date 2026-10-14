# Optional Wireshark capture filters

Capture filters limit what is recorded, unlike display filters. Leave the capture filter blank initially if you are learning, then use display filters after packets have been captured.

- EIGRP only: `ip proto 88`
- OSPF only: `ip proto 89`
- EIGRP and OSPF: `ip proto 88 or ip proto 89`

Recommended learning sequence: capture all packets on the link first, then apply display filter `eigrp` or `ospf` so you can return to the full packet list without restarting the capture.
