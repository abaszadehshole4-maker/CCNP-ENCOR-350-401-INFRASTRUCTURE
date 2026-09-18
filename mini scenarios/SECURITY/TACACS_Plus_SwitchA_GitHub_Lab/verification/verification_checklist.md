# Verification Checklist

## SwitchA

Run:

```cisco
show running-config | section aaa
show running-config | section tacacs
show running-config | section line vty
ping 192.168.1.100
```

## Expected AAA

```text
aaa new-model
aaa authentication login primary group tacacs+ local
```

## Expected TACACS+

Modern IOS:

```text
tacacs server TACACS-SERVER
 address ipv4 192.168.1.100
 key boson
```

Legacy IOS:

```text
tacacs-server host 192.168.1.100 key boson
```

## Expected VTY

```text
line vty 0 4
 login authentication primary
```

## Remote test

From a reachable client:

```text
ssh <username>@<SwitchA-IP>
```

Authenticate with the account configured on the TACACS+ server.

## Debugging

```cisco
terminal monitor
debug aaa authentication
debug tacacs
```

After the test:

```cisco
undebug all
```
