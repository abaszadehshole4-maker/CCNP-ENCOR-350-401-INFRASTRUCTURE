# Purpose and tasks

## Scenario
You are configuring **dynamic NAT** on RouterA. `GigabitEthernet0/0` connects to ISP1, and `GigabitEthernet0/1` connects to the inside network `10.1.1.0/26`.

## Objectives
1. Use **standard ACL 1** to permit addresses from the entire inside subnet.
2. Create a NAT pool named **`exsim`**.
3. Start the pool at **`192.168.1.101`** with netmask **`255.255.255.0`**.
4. Make the pool large enough to provide a unique translated address for every usable host address in the inside subnet.
5. Associate ACL 1 with the NAT pool.

## Design choices
- ACL wildcard mask: `0.0.0.63`, matching `10.1.1.0/26`.
- Pool range: `192.168.1.101–192.168.1.164` (64 addresses).
- `GigabitEthernet0/0`: `ip nat outside`.
- `GigabitEthernet0/1`: `ip nat inside` and `10.1.1.1/26`.

## Learning outcomes
After completing the lab, you should be able to explain the roles of inside/outside interfaces, standard ACL matching, NAT pool sizing, and verification of dynamic NAT translations.

## Scope and assumptions
The exercise is limited to dynamic NAT configuration. It does not provide ISP interface addressing, a default route, an ISP return route, or host details. Add those only when your lab topology specifies them. No passwords were provided or required by the task; do not reuse real passwords in lab files.
