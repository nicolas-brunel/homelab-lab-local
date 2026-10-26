# OPNsense configuration (track A)

OPNsense 26.7 VM with one network card per zone. The exported XML configuration is **not** published (it contains password hashes); this page documents the settings instead.

## Interfaces

| Interface | Card | IPv4 | Bits |
|---|---|---|---|
| LAN | em1 | 10.2.0.97 | 28 |
| OPT1 | em2 | 10.2.0.65 | 27 |
| OPT2 | em3 | 10.2.0.1 | 26 |
| OPT3 | em4 | 10.2.0.113 | 28 |

WAN `em0` gets its address by DHCP from VMware NAT (192.168.10.0/24).

## Aliases

| Name | Type | Content | Description |
|---|---|---|---|
| DHCP_SERVER | Port(s) | 67 | Port DHCP serveur |
| SRV_AD | Host(s) | 10.2.0.70 | Contrôleur de domaine |
| LNX01 | Host(s) | 10.2.0.72 | Serveur GLPI |
| SIEM01 | Host(s) | 10.2.0.102 | Serveur Wazuh |
| LAB_NETS | Network(s) | 10.2.0.0/24 | Tous les réseaux du lab |
| PORT_DNS | Port(s) | 53 | DNS |
| PORT_HTTP | Port(s) | 80 | HTTP |
| PORT_WEB | Port(s) | 80, 443 | Web sortant |
| WAZUH_PORTS | Port(s) | 1514, 1515 | Ports agents Wazuh |

## Rules

Rules are evaluated top to bottom, first match wins. Direction In, IPv4, Quick.

### ADMINISTRATION

Automatic *Default allow LAN to any* rules and the anti-lockout rule are kept.

### SERVEURS

| # | Action | Proto | Source | Destination | Port | Description |
|---|---|---|---|---|---|---|
| 1 | Pass | any | SERVEURS network | any | any | Serveurs vers tout |

### UTILISATEURS

| # | Action | Proto | Source | Destination | Port | Log | Description |
|---|---|---|---|---|---|---|---|
| 1 | Pass | UDP | any | any | DHCP_SERVER |  | DHCP relay |
| 2 | Pass | TCP | UTILISATEURS network | SIEM01 | WAZUH_PORTS |  | Agents Wazuh vers SIEM01 |
| 3 | Block | any | UTILISATEURS network | ADMINISTRATION network | any | ✓ | Bloque Utilisateurs vers Admin |
| 4 | Block | any | UTILISATEURS network | This Firewall | any | ✓ | Bloque accès au pare-feu |
| 5 | Pass | any | UTILISATEURS network | any | any |  | Utilisateurs vers tout |

Rule 2 is a narrow exception (one host, two ports) placed above the block. Rule 4 stops users from reaching the firewall GUI on their own gateway address.

### DMZ

| # | Action | Proto | Source | Destination | Port | Log | Description |
|---|---|---|---|---|---|---|---|
| 1 | Pass | TCP/UDP | DMZ network | SRV_AD | PORT_DNS |  | DMZ vers DNS |
| 2 | Pass | TCP | DMZ network | LNX01 | PORT_HTTP |  | DMZ vers GLPI |
| 3 | Pass | TCP | DMZ network | SIEM01 | WAZUH_PORTS |  | DMZ vers SIEM (agent Wazuh) |
| 4 | Block | any | DMZ network | LAB_NETS | any | ✓ | Bloque DMZ vers le lab |
| 5 | Pass | TCP | DMZ network | any | PORT_WEB |  | DMZ vers Internet (web) |

Rule 4 comes before rule 5, so *any* in rule 5 can only mean the Internet.

## DHCP relay

Services → DHCRelay: destination `SRV-AD` (10.2.0.70), relay enabled on interface UTILISATEURS. Equivalent of `ip helper-address 10.2.0.70` on Cisco.

## Port forwarding (DMZ publication)

Firewall → NAT → Destination NAT: WAN, TCP, destination *WAN address* port 443 → redirect to `10.2.0.114:443` (PROXY01), with the associated filter rule generated automatically.

## Logging, GUI exposure and WAN options

| Menu | Setting | Value | Why |
|---|---|---|---|
| Firewall → Settings → Advanced | Log default block / bogons / private | ✓ | unexpected traffic is visible |
|  | Log default pass | ✗ | removes NTP / anti-lockout noise |
|  | Log automatic source NAT | ✗ | noise |
| System → Settings → Administration | Listen Interfaces | **ADMINISTRATION only** | the GUI must never answer on the WAN; frees port 443 for the DMZ publication |
| Interfaces → [WAN] | Block private networks | ✗ (lab only) | the lab WAN is itself private (VMware NAT); keep ✓ in production |
| Interfaces → [DMZ] | Block private / bogon | ✗ | internal zone |

## Web interface certificate (v1.1)

System → Trust: LAB-ROOT-CA imported as an authority (certificate only, no private key); certificate `fw01.lab.local` created as a CSR on OPNsense, signed by the CA, imported back, and selected in System → Settings → Administration.

## Remote syslog

System → Settings → Logging → Remote: UDP to `10.2.0.102:514` (Wazuh SIEM01), all applications.
