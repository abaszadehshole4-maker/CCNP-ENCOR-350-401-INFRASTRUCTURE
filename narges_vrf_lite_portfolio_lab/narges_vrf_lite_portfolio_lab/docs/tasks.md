# Lab Tasks — Multi-VRF Enterprise Segmentation

## Part 1 — Base
1. Import the EVE-NG topology.
2. Start all nodes.
3. Apply the provided node configurations.
4. Verify all physical interfaces are up.

## Part 2 — VRF-Lite
1. Confirm `FINANCE` and `ENGINEERING` VRFs exist on all three routers.
2. Confirm user-facing subinterfaces use dot1Q 110 and 120.
3. Verify IPv4 and IPv6 addresses are in the correct VRFs.

## Part 3 — IPv4 and IPv6 static routing
1. Verify both edge routers can reach the opposite-site LAN in the same VRF.
2. Verify the transit router has paths to both edge LANs in both VRFs.
3. Verify default routes exist at the edge for both VRFs.

## Part 4 — Layer 2
1. Create VLANs 110 and 120.
2. Configure trunks and allow only VLANs 110 and 120.
3. Form LACP Port-channel10 between SW1-DIST-A and SW3-ACCESS-B.
4. Configure client-facing ports as access ports.
5. Enable PortFast on client ports.

## Part 5 — Security
1. Configure the local admin account.
2. Configure SCRYPT privileged access.
3. Enable AAA with the local database.
4. Verify console and VTY authentication.

## Part 6 — Validation challenges
Intentionally introduce one fault at a time:
- remove one VRF route
- move a host to the wrong VLAN
- remove VLAN 120 from a trunk
- shut one LACP member
- apply the wrong VRF to one routed interface

Record the symptom, command used to isolate it, and fix.

## Acceptance criteria

- FIN-PC1 ↔ FIN-PC2: IPv4 and IPv6 PASS
- ENG-PC1 ↔ ENG-PC2: IPv4 and IPv6 PASS
- FINANCE ↔ ENGINEERING: FAIL (expected isolation)
- LACP: Port-channel10 bundled
- Client ports: PortFast enabled
- Local AAA authentication: PASS
