#!/usr/bin/env bash
# MGMT1 is an Ubuntu/Debian-style Linux host on 10.110.30.50/24.
# Adapt package names if your EVE-NG Linux image is Alpine/CentOS/etc.
set -e

sudo ip addr replace 10.110.30.50/24 dev eth0
sudo ip route replace default via 10.110.30.254

sudo apt-get update
sudo apt-get install -y freeradius chrony rsyslog snmp snmptrapd nfdump

# RADIUS test account
sudo sed -i 's/^#\?default_auth_type.*/default_auth_type = PAP/' /etc/freeradius/3.0/radiusd.conf || true
printf 'netadmin Cleartext-Password := "NetAdmin!2026"\n' | sudo tee /etc/freeradius/3.0/mods-config/files/authorize >/dev/null
printf 'client eve-lab {\n ipaddr = 10.110.0.0/16\n secret = LabRadius!2026\n shortname = eve-lab\n}\n' | sudo tee /etc/freeradius/3.0/clients.conf >/dev/null

# Chrony local time source for lab devices
sudo sed -i 's/^pool /# pool /' /etc/chrony/chrony.conf
printf '\nlocal stratum 5\nallow 10.110.0.0/16\n' | sudo tee -a /etc/chrony/chrony.conf >/dev/null

# Syslog receiver
printf '\nmodule(load="imudp")\ninput(type="imudp" port="514")\n' | sudo tee /etc/rsyslog.d/10-eve-network.conf >/dev/null

# SNMP trap receiver
printf 'disableAuthorization yes\n' | sudo tee /etc/snmp/snmptrapd.conf >/dev/null

# NetFlow v9 collector (nfcapd writes files under /var/log/netflow)
sudo mkdir -p /var/log/netflow
sudo chown nobody:nogroup /var/log/netflow || true

sudo systemctl enable --now freeradius || true
sudo systemctl enable --now chrony || true
sudo systemctl enable --now rsyslog || true
sudo systemctl enable --now snmptrapd || true

# Start NetFlow collector on UDP/9999
sudo nohup nfcapd -w -D -T all -l /var/log/netflow -p 9999 >/var/log/netflow/nfcapd.log 2>&1 || true

echo 'MGMT1 setup complete.'
