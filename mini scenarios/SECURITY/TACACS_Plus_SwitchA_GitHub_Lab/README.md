# TACACS+ AAA Authentication for Cisco SwitchA

**Creator:** Sholeh Abaszadeh  
**Lab type:** Cisco IOS AAA / TACACS+  
**Purpose:** Configure SwitchA so remote VTY login attempts are authenticated through a TACACS+ server.

## Scenario

The company network contains two Cisco switches, **SwitchA** and **SwitchB**. A TACACS+ server is connected to SwitchA.

The supplied lab requirements specify:

- TACACS+ server IP address: `192.168.1.100`
- TACACS+ encryption key: `boson`
- Configure AAA on SwitchA.
- Configure the TACACS+ server parameters.
- Create an authentication list named `primary`.
- Use the TACACS+ server as the authentication method for remote logins.
- Apply the `primary` authentication list to the first five VTY lines.

These requirements are taken directly from the supplied scenario. fileciteturn0file0L6-L11

## Topology

```text
                         192.168.1.100
                    +-------------------+
                    |    TACACS+ Server |
                    +---------+---------+
                              |
                              |
                         192.168.1.1
                    +---------+---------+
                    |      SwitchA      |
                    |   VTY 0 - 4       |
                    +---------+---------+
                              |
                              |
                    +---------+---------+
                    |      SwitchB      |
                    +-------------------+
```

> The exact interface numbers and SwitchB addressing are not specified in the supplied task. Therefore, the configuration below focuses on the required SwitchA AAA/TACACS+ functions and leaves physical/interface addressing as an implementation choice.

## Addressing

| Device | Address | Role |
|---|---|---|
| SwitchA | `192.168.1.1/24`* | TACACS+ client |
| TACACS+ Server | `192.168.1.100/24` | AAA server |
| SwitchB | Not specified | Second Cisco switch |

`*` The SwitchA address is a practical lab value used to demonstrate reachability; the supplied task specifies the server address but does not specify SwitchA's address.

## SwitchA Configuration

Two IOS syntax variants are provided because Cisco IOS releases differ.

### Preferred modern IOS syntax

```cisco
enable
configure terminal

aaa new-model

tacacs server TACACS-SERVER
 address ipv4 192.168.1.100
 key boson

aaa authentication login primary group tacacs+ local

line vty 0 4
 login authentication primary
 transport input ssh telnet

end
write memory
```

### Legacy IOS syntax

If the image does not accept the `tacacs server` configuration mode, use:

```cisco
enable
configure terminal

aaa new-model

tacacs-server host 192.168.1.100 key boson

aaa authentication login primary group tacacs+ local

line vty 0 4
 login authentication primary
 transport input ssh telnet

end
write memory
```

## Why `local` is included

The supplied task requires TACACS+ as the authentication method. The command:

```cisco
aaa authentication login primary group tacacs+ local
```

tries TACACS+ first and uses the local username database if the TACACS+ server is unavailable.

If the lab specifically requires **TACACS+ only**, use:

```cisco
aaa authentication login primary group tacacs+
```

The supplied scenario does not specify a local fallback policy, so both versions are documented rather than silently choosing one.

## TACACS+ Server

The supplied task specifies the server IP and shared encryption key, but does not specify the TACACS+ server software or user credentials.

On the TACACS+ server, configure:

```text
Server IP:       192.168.1.100
Shared secret:   boson
```

Create at least one test user on the TACACS+ server, for example:

```text
Username: <your-test-user>
Password: <your-test-password>
```

Use the credentials required by your TACACS+ server implementation.

## Verification

### 1. Verify AAA is enabled

```cisco
show running-config | section aaa
```

Expected configuration should include:

```text
aaa new-model
aaa authentication login primary ...
```

### 2. Verify the TACACS+ server

Modern IOS:

```cisco
show running-config | section tacacs
```

Expected:

```text
tacacs server TACACS-SERVER
 address ipv4 192.168.1.100
 key boson
```

Legacy IOS:

```cisco
show running-config | include tacacs-server
```

### 3. Verify VTY lines

```cisco
show running-config | section line vty
```

Expected:

```text
line vty 0 4
 login authentication primary
```

### 4. Verify IP connectivity

From SwitchA:

```cisco
ping 192.168.1.100
```

The ping should succeed before troubleshooting TACACS+ authentication.

### 5. Test remote authentication

From another device:

```text
SSH/Telnet -> SwitchA
```

Enter the username/password configured on the TACACS+ server.

### 6. Optional debugging

Use carefully in a lab:

```cisco
terminal monitor
debug aaa authentication
debug tacacs
```

After testing, disable debugging:

```cisco
undebug all
```

## Troubleshooting

### TACACS+ authentication fails

Check:

```cisco
ping 192.168.1.100
show running-config | section aaa
show running-config | section tacacs
show running-config | section line vty
```

Check that:

1. The server is reachable.
2. The shared key is exactly `boson` on both sides.
3. The username exists on the TACACS+ server.
4. The TACACS+ server recognizes SwitchA as a client.
5. The VTY lines use `login authentication primary`.
6. The TACACS+ service is running on the server.

### The `tacacs server` command is rejected

Use the legacy syntax:

```cisco
tacacs-server host 192.168.1.100 key boson
```

### VTY login does not use TACACS+

Check:

```cisco
show running-config | section line vty
```

The first five VTY lines must be:

```cisco
line vty 0 4
 login authentication primary
```

## Learning objectives

This lab demonstrates:

- AAA framework activation with `aaa new-model`
- TACACS+ server definition
- TACACS+ shared-secret configuration
- Named AAA authentication lists
- Applying an AAA authentication list to VTY lines
- Basic remote-access authentication troubleshooting

## Portfolio evidence

Recommended screenshots for GitHub:

1. `show running-config | section aaa`
2. `show running-config | section tacacs`
3. `show running-config | section line vty`
4. Successful `ping 192.168.1.100`
5. Successful SSH/Telnet login using the TACACS+ account

## Source task

The original supplied scenario is preserved in:

`notes/original_scenario.txt`
