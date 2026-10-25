# Cisco configuration (track B)

Same IP plan and same security rules as the OPNsense version, translated into IOS.

| File | Device | Content |
|---|---|---|
| [`SW-LAB.cfg`](SW-LAB.cfg) | Catalyst 2960 | VLANs 10/20/30/40 + parking 999, access ports with PortFast, BPDU guard and port security, 802.1Q trunks (native VLAN 999), management SVI in VLAN 30, SSH only, NTP, syslog |
| [`R-LAB.cfg`](R-LAB.cfg) | ISR 1941 / 2901 | router-on-a-stick sub-interfaces, DHCP relay, NAT overload + static PAT 443 to the DMZ proxy, extended ACLs for the users and DMZ zones, SSH restricted to the admin network |
| [`L3-switch-variant.cfg`](L3-switch-variant.cfg) | Catalyst 3560 / 3650 | inter-VLAN routing with SVIs, routed uplink to the router |

## Port plan

| Device | Port | Mode | VLAN | Connected to |
|---|---|---|---|---|
| Router | G0/1 | routed (outside) | — | ISP box |
| Router | G0/0 | trunk (sub-interfaces) | 10, 20, 30, 40 | switch Gi0/1 |
| Switch | Gi0/1 | trunk | 10, 20, 30, 40 (native 999) | router G0/0 |
| Switch | Gi0/2 | trunk | 10, 20, 30, 40 (native 999) | Proxmox NIC |
| Switch | Fa0/1–4 | access | 30 | admin PCs |
| Switch | Fa0/5–8 | access | 10 | user PCs |
| Switch | Fa0/9–24 | access, shutdown | 999 | unused |

## Design notes

- ACLs are **stateless**: return traffic for sessions opened from other zones is allowed with `established`.
- ACLs are applied **inbound** on the sub-interface of the zone they restrict (users, DMZ). Servers and admin are not filtered, as in the OPNsense version.
- Before applying an ACL remotely: `reload in 10`, then `reload cancel` once access is confirmed.
- Secrets are placeholders (`<enable-secret>`, `<admin-secret>`).
