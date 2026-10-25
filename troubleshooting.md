# Troubleshooting log

Real problems met while building this lab (30 entries), with the cause found and the fix applied. Most of them are classic issues that also happen in production environments.

| Symptom | Cause | Fix |
|---|---|---|
| Host PC cannot reach 10.2.0.70; reply from 212.x.x.x “destination network unreachable” | no route to the lab: traffic leaves through the home box | route -p add 10.2.0.0 mask 255.255.255.128 10.2.0.97 |
| Nothing answers in the lab after rebooting the laptop | VMs off (OPNsense / SRV-AD not started) | start order OPNsense → SRV-AD → others; wait |
| OPNsense WAN has no IP after install | WAN assigned to the host-only card | reassign interfaces using the MAC table |
| Disk added to a VM invisible (Proxmox, orange) | pending hot-plug change | full shutdown/start from the hypervisor |
| D: unavailable on FS01 | CD-ROM holds D: | move the CD-ROM to E: |
| “Interface inconnue”, NETLOGON 5774, GroupPolicy 1054 after changing the DC's IP | AD/DNS still bound to the old IP | ipconfig /registerdns, restart netlogon, delete old A records, reboot the DC |
| DHCP event 1041; firewall profile “Privé” on the DC | the DC took its IP by DHCP | static IP before promotion |
| FS01 does not answer ping/SMB (Server 2025) | File and Printer Sharing rules disabled | Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502" |
| Local account refused after domain join | logon screen targets the domain | use .\Administrateur |
| Administrateur gets “accès refusé” on shares | by design (DL groups only) | use \\FS01\D$ or work locally |
| gpupdate hangs; wallpaper not applied | Group Policy client stuck | check DC/SYSVOL/time, then restart the client |
| Alias rejects 1514 / 67 | alias type left on Host(s) | choose Port(s) first |
| GLPI login refused for a business user in the evening | AD logon hours apply to LDAP | test in hours or use Informatique accounts |
| GLPI LDAP “Bad search filter (-7)” | matching-rule filter rejected / spaces in DN | (&(objectClass=user)(objectCategory=person)), DN without spaces |
| GLPI does not load right after boot | Apache/MariaDB still starting | wait one minute |
| lnx01.lab.local unknown from the host PC | host uses the home box as DNS | use IPs from the host |
| Scheduled backup on the DC refuses nas01\SVC-Backup | a DC has no local accounts | domain account LAB\SVC-Backup with the same name and password as on the NAS |
| Share login refused | Linux user names are case-sensitive | type SVC-Backup exactly |
| FS01 backup stuck at 0 KB, VM laggy | system state / VSS stuck | wbadmin stop job, reboot, back up D: only |
| Backup files dated wrong on the NAS | NAS clock 12 h off | OMV NTP → 10.2.0.70, Europe/Paris |
| chrony marks SRV-AD “^?” | DC on its own CMOS clock | w32tm manualpeerlist pool.ntp.org /reliable:yes |
| systemd-timesyncd not found (Ubuntu 26.04) | chrony is the time service | /etc/chrony/sources.d/lab.sources |
| Ubuntu mirror test fails | router/DC not started or IP not saved | start OPNsense + SRV-AD, check static config |
| Wazuh indexer slow / crashing | heap left at 1 GB | jvm.options -Xms/-Xmx = half the RAM |
| No OPNsense alerts in Wazuh | 87701 is no_log; block rules not logging | Log ✓ on block rules; look for 87702 |
| OPNsense logs flooded by devd cd0 | empty virtual CD drive | remove the CD drive from the VM |
| wazuh-logtest: “No decoder matched” | pasted line starts with spaces | paste the raw line starting with the date |
| Agent “disconnected” | VM off, or agent stopped | start the VM / service; investigate if running |
| PROXY01 → SIEM01 blocked | SIEM01 off, or Apply not clicked | start SIEM01, apply the rules |
| RAM at 97 % with all VMs | VMs reserve memory; iGPU reserved 4 GB | run by scenario; UMA buffer 1G in BIOS |

## Method used

1. Reproduce the problem and note the exact error message or event ID.
2. Check from the bottom up: link and VLAN, IP and route, DNS, firewall rule, service, application.
3. Change one thing at a time and test again.
4. Write down symptom, cause and fix here, so the next occurrence takes minutes.
