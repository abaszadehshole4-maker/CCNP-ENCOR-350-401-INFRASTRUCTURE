# Wireshark filters for MST / STP

Capture a switch-to-switch link inside EVE-NG. STP/MST BPDUs are link-local and generally are not forwarded like normal user traffic, so capturing an endpoint link may not show them.

## Display filters

| Goal | Display filter |
|---|---|
| STP / RSTP / MSTP BPDUs | `stp` |
| Link-local bridge control destination | `eth.dst == 01:80:c2:00:00:00` |
| Ethernet II destination for STP BPDUs | `eth.dst == 01:80:c2:00:00:00 && stp` |
| All traffic on the captured link | *(leave display filter empty)* |

Some Wireshark versions label decoded BPDU details under STP, RSTP, or MSTP depending on the capture and dissector. If `stp` matches nothing, clear the filter and inspect the packet list or try the destination MAC filter.

## Capture filters

Set these before starting capture; capture filters use libpcap syntax.

| Goal | Capture filter |
|---|---|
| STP/MST BPDU destination | `ether dst 01:80:c2:00:00:00` |
| Capture all Ethernet traffic | *(leave blank)* |

## Capture workflow

1. Start packet capture on a switch-to-switch trunk link in EVE-NG.
2. Start/restart is usually not needed; switches send periodic BPDUs automatically.
3. Apply display filter `stp` and press Enter.
4. Select a BPDU and expand its STP/MST information if decoded.
5. Compare root bridge/bridge ID and port ID details with `show spanning-tree mst 1` and `show spanning-tree mst 2` on the switches.
6. Capture again while shutting and restoring one trunk, then compare convergence and BPDU changes.
7. Save your real capture as `.pcapng` in `evidence/`.

## Evidence expected

- BPDU capture on an inter-switch link
- `show spanning-tree mst configuration` from all three switches
- Output showing SW1 root for instance 1 and SW2 root for instance 2
- Before/after state when a trunk is shut and restored
