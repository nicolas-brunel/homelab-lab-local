# Addressing, inventory and flows

All addresses are private addresses of an isolated lab.

## Addressing plan (VLSM)

Block `10.2.0.0/24`, split largest need first. Gateways are the first usable address of each subnet.

| Zone / VLAN | Need | Network | Mask | Usable range | Gateway | Broadcast |
|---|---|---|---|---|---|---|
| UTILISATEURS — 10 | 50 | 10.2.0.0/26 | 255.255.255.192 | .1 – .62 | 10.2.0.1 | 10.2.0.63 |
| SERVEURS — 20 | 20 | 10.2.0.64/27 | 255.255.255.224 | .65 – .94 | 10.2.0.65 | 10.2.0.95 |
| ADMINISTRATION — 30 | 10 | 10.2.0.96/28 | 255.255.255.240 | .97 – .110 | 10.2.0.97 | 10.2.0.111 |
| DMZ — 40 | ≤ 14 | 10.2.0.112/28 | 255.255.255.240 | .113 – .126 | 10.2.0.113 | 10.2.0.127 |
| Reserve | — | 10.2.0.128/25 | 255.255.255.128 | .129 – .254 | — | 10.2.0.255 |
| WAN (VMware NAT) | — | 192.168.10.0/24 | 255.255.255.0 | DHCP by VMware | 192.168.10.2 | — |

### DHCP

| Scope | Range | Options | Served by |
|---|---|---|---|
| VLAN10-Utilisateurs (10.2.0.0/26) | 10.2.0.10 – 10.2.0.60 | 003 Router 10.2.0.1 · 006 DNS 10.2.0.70 · 015 Domain lab.local | SRV-AD, through OPNsense DHCP relay |

Servers, admin and DMZ machines use static addresses.

## Machine inventory

| # | VM (VMware) | Hostname / FQDN | OS | Role |
|---|---|---|---|---|
| 01 | 01 - OPNSense | fw01.lab.local | OPNsense 26.7 | firewall, router, NAT, relay |
| 02 | 02 - SRV-AD | SRV-AD.lab.local | Win Server 2022 Std | AD DS, DNS, DHCP, NTP |
| 03 | 03 - SIEM01 | siem01.lab.local | Ubuntu Server 26.04 | Wazuh SIEM |
| 04 | 04 - NAS01 | nas01.lab.local | OpenMediaVault | backup storage, RAID 1 |
| 05 | 05 - FS01 | FS01.lab.local | Win Server 2025 DC | file server (AGDLP) |
| 06 | 06 - LNX01 | lnx01.lab.local | Debian 13 | GLPI 12 |
| 07 | 07 - PROXY01 | proxy01.lab.local | Debian 13 (no GUI) | Nginx reverse proxy |
| 08 | 08 - CLT01 | CLT01.lab.local | Windows 11 Pro | client workstation |
| 09 | 09 - CA01 | CA01.lab.local | Win Server 2025 DC | Enterprise root CA (AD CS) |

## Network configuration (track A)

| VM | Interface | IP / prefix | Gateway | DNS | VMware network |
|---|---|---|---|---|---|
| OPNsense | em0 WAN | DHCP (192.168.10.136) | 192.168.10.2 | — | NAT (VMnet8) |
|  | em1 ADMIN | 10.2.0.97/28 | — | — | VMnet1 host-only |
|  | em2 SERVEURS | 10.2.0.65/27 | — | — | segment SRV20 |
|  | em3 UTILISATEURS | 10.2.0.1/26 | — | — | segment LAN10 |
|  | em4 DMZ | 10.2.0.113/28 | — | — | segment DMZ40 |
| SRV-AD | Ethernet0 | 10.2.0.70/27 | 10.2.0.65 | 127.0.0.1 | SRV20 |
| FS01 | Ethernet0 | 10.2.0.71/27 | 10.2.0.65 | 10.2.0.70 | SRV20 |
| LNX01 | ens33 | 10.2.0.72/27 | 10.2.0.65 | 10.2.0.70 | SRV20 |
| NAS01 | ens33 | 10.2.0.73/27 | 10.2.0.65 | 10.2.0.70 | SRV20 |
| SIEM01 | ens33 | 10.2.0.102/28 | 10.2.0.97 | 10.2.0.70 | VMnet1 |
| PROXY01 | ens33 | 10.2.0.114/28 | 10.2.0.113 | 10.2.0.70 | DMZ40 |
| CLT01 | Ethernet0 | DHCP (10.2.0.10) | 10.2.0.1 | 10.2.0.70 | LAN10 |
| CA01 | Ethernet0 | 10.2.0.74/27 | 10.2.0.65 | 10.2.0.70 | SRV20 |
| Host PC | VMnet1 adapter | 10.2.0.101/28 | none | home box | VMnet1 |

## Network devices (track B)

| Device | Interface | IP / prefix | Access |
|---|---|---|---|
| R-LAB (router) | G0/0.30 · .20 · .10 · .40 | 10.2.0.97 · .65 · .1 · .113 | SSH admin@10.2.0.97 (from ADMIN only) |
|  | G0/1 (outside) | DHCP from the home box | — |
| SW-LAB (switch) | VLAN 30 SVI | 10.2.0.98/28, gateway .97 | SSH admin@10.2.0.98 |
| Proxmox (pve) | vmbr0 (VLAN 30) | 10.2.0.100/28, gateway .97 | https://10.2.0.100:8006 (root@pam) |
| Admin PC | switch access port VLAN 30 | 10.2.0.101/28, gateway .97 | — |

## DNS records

Zone `lab.local` and reverse zone `0.2.10.in-addr.arpa` on SRV-AD.

| Name | Type | Address | PTR | Created by |
|---|---|---|---|---|
| srv-ad | A | 10.2.0.70 | yes | automatic (DC) |
| FS01, CLT01, CA01 | A | 10.2.0.71 · 10.2.0.10 · 10.2.0.74 | yes | automatic (domain members) |
| lnx01 | A | 10.2.0.72 | yes | manual |
| nas01 | A | 10.2.0.73 | yes | manual |
| siem01 | A | 10.2.0.102 | yes | manual |
| proxy01 | A | 10.2.0.114 | yes | manual |

## Web interfaces

| Service | URL from the host PC (admin) | URL from inside the lab | Account (login source) | Reachable from |
|---|---|---|---|---|
| OPNsense | https://10.2.0.97 | — | root | ADMIN only (GUI listens on ADMINISTRATION only) · certificate fw01.lab.local |
| Wazuh dashboard | https://10.2.0.102 | https://siem01.lab.local | admin | ADMIN only · certificate siem01.lab.local |
| OpenMediaVault | http://10.2.0.73 | http://nas01.lab.local | admin (web) | ADMIN, SERVEURS |
| GLPI (internal) | http://10.2.0.72 | http://lnx01.lab.local | glpi (Base interne GLPI) · AD users (AD lab.local) | all internal zones |
| GLPI (published) | https://192.168.10.136 (or https://glpi.lab.local with a hosts entry) | — | same as above | “Internet” side, through OPNsense NAT → PROXY01 → LNX01 · certificate glpi.lab.local |
| CA (CRL, CA certificate) | http://10.2.0.74/CertEnroll/ | http://ca01.lab.local/CertEnroll/ | anonymous read | internal zones (not the DMZ) |
| CA console | certsrv.msc on CA01 | — | LAB\Administrateur | admins only |
| File shares | \\FS01 (from domain PCs) | \\FS01\Commun … | AD users | domain members |
| Backup share | \\nas01\Sauvegardes | \\10.2.0.73\Sauvegardes | nas01\SVC-Backup | servers, admin |
| Admin share FS01 | \\FS01\D$\PARTAGES |  | LAB\Administrateur | admins only |

## SSH access

| Server | Command (from host PC) | Authentication | Rules |
|---|---|---|---|
| LNX01 | ssh tech1@10.2.0.72 | SSH key only | root login off, password off; ufw: 22 from 10.2.0.96/28 only |
| SIEM01 | ssh nicolas@10.2.0.102 | password (+ key optional) | admin network only |
| PROXY01 | ssh nicolas@10.2.0.114 | password (+ key optional) | from ADMIN only (DMZ cannot initiate) |
| NAS01 | ssh <user>@10.2.0.73 | member of group _ssh | root login off (or SSH disabled) |

## Allowed flows between zones

Everything not listed is denied (default deny).

| From | To | Port / proto | Purpose | OPNsense rule |
|---|---|---|---|---|
| UTILISATEURS | any (relay) | UDP 67 | DHCP requests | DHCP relay |
| UTILISATEURS | SIEM01 | TCP 1514, 1515 | Wazuh agent | Agents Wazuh vers SIEM01 |
| UTILISATEURS | ADMINISTRATION | any | **blocked + logged** | Bloque Utilisateurs vers Admin |
| UTILISATEURS | This Firewall | any | **blocked + logged** | Bloque accès au pare-feu |
| UTILISATEURS | any | any | servers + Internet | Utilisateurs vers tout |
| SERVEURS | any | any | servers out, agents, NTP, backups | Serveurs vers tout |
| ADMINISTRATION | any | any | administration | default allow LAN |
| DMZ | SRV-AD | TCP/UDP 53 | DNS | DMZ vers DNS |
| DMZ | LNX01 | TCP 80 | proxy → GLPI | DMZ vers GLPI |
| DMZ | SIEM01 | TCP 1514, 1515 | Wazuh agent | DMZ vers SIEM |
| DMZ | 10.2.0.0/24 | any | **blocked + logged** | Bloque DMZ vers le lab |
| DMZ | any | TCP 80, 443 | updates | DMZ vers Internet (web) |
| WAN | PROXY01 | TCP 443 | GLPI publication | Destination NAT + linked rule |
| OPNsense | SIEM01 | UDP 514 | syslog | (firewall's own traffic) |
| Agents (all) | SIEM01 | TCP 1514/1515 | events / enrolment | see above |
| SRV-AD, FS01, LNX01, CA01 | NAS01 | TCP 445 | backups (SMB) | same zone, no rule |
| LNX01 (GLPI) | SRV-AD | TCP 636 | LDAPS bind (encrypted) | same zone, no rule |
| Domain members | CA01 | TCP 135 + RPC | certificate enrollment | same zone / Utilisateurs vers tout |
| Internal clients | CA01 | TCP 80 | CRL and CA certificate download | same zone / existing rules |
| SRV-AD | pool.ntp.org | UDP 123 | time source of the domain | Serveurs vers tout |

## Start-up order

| Start | VM | Wait before next | Why |
|---|---|---|---|
| 1 | OPNsense | ≈ 1 min | routing between zones, Internet |
| 2 | SRV-AD | 2–3 min | DNS, AD, DHCP, time — everyone depends on it |
| 3 | CA01 | ≈ 1 min | certificate enrollment, CRL publication |
| 4 | SIEM01 | 2–3 min | ready to receive logs from the others |
| 5 | NAS01 | ≈ 1 min | backup target |
| 6 | FS01 | ≈ 1 min | needs AD |
| 7 | LNX01 | ≈ 1 min | GLPI needs AD/DNS for LDAPS; Apache/MariaDB start slowly |
| 8 | PROXY01 | 30 s | needs LNX01 |
| 9 | CLT01 | — | last: domain, shares, GPOs available |

Shut down in reverse order, always cleanly.
