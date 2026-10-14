# EVE-NG evidence folder

Put your **own, genuine** captures and screenshots in this folder. The chat did not include an accessible `.pcap` or `.pcapng` attachment during package creation, so no capture evidence is bundled here.

Suggested filenames:

- `01-underlay-ikev2.pcapng`
- `02-underlay-esp.pcapng`
- `03-tunnel-ospf.pcapng` (only if you captured inner/tunnel-side packets)
- `04-show-crypto-ikev2-sa.png`
- `05-show-crypto-ipsec-sa.png`
- `06-show-ip-ospf-neighbor.png`
- `07-wireshark-esp-filter.png`

Before committing captures publicly, inspect them for secrets, unrelated packets, identifying addresses, usernames, or customer data. If the capture is large, GitHub may reject it; consider keeping large PCAPNGs outside the repository and linking a sanitized sample or describing the evidence instead.
