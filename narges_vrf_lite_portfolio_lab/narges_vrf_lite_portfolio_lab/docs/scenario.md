# Scenario Brief

## Business requirement

The organization has two departments located at two sites. Their VLANs share physical switching infrastructure, but their Layer-3 traffic must remain isolated.

## Engineering constraints

- Use two VRFs consistently across all three routers.
- Support IPv4 and IPv6 in each VRF.
- Use dot1Q router-on-a-stick at the user-facing routers.
- Use static routing inside each VRF.
- Edge routers should prefer a default route toward the transit router.
- Transit must know both site LANs for both VRFs.
- Do not leak routes between VRFs.
- Use VLAN 110 for FINANCE and VLAN 120 for ENGINEERING.
- Use LACP between SW1-DIST-A and SW3-ACCESS-B.
- Use PortFast on host-facing ports.
- Use local AAA with SCRYPT secrets.

## Suggested study sequence

### Phase 1
Build the topology and make every physical link up.

### Phase 2
Create VRFs and move Layer-3 interfaces into the correct VRF.

### Phase 3
Configure IPv4 static routes and verify each VRF.

### Phase 4
Add IPv6 addresses and IPv6 static routes.

### Phase 5
Configure VLANs, trunks, access ports, and EtherChannel.

### Phase 6
Enable AAA and verify local authentication.

### Phase 7
Break the lab intentionally:
- remove one static route
- put a port in the wrong VLAN
- remove a VLAN from the trunk allowed list
- place a transit interface in the wrong VRF

Then troubleshoot using the verification sheets.

## What success looks like

- Finance PC at Site A reaches Finance PC at Site B.
- Engineering PC at Site A reaches Engineering PC at Site B.
- IPv6 works for the same two cases.
- Finance-to-Engineering tests fail as designed.
- EtherChannel forms as a single logical bundle.
- Host ports are forwarding immediately because of PortFast.
- AAA authenticates the configured local user.
