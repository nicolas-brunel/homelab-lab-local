# Screenshots

Proof that the lab runs. Suggested captures (name them with the test number from [`../acceptance-tests.md`](../acceptance-tests.md)):

- `01-clt01-ipconfig.png` — DHCP address and DHCP server 10.2.0.70 (relay works)
- `03-firewall-live-view-block.png` — blocked user → admin traffic in OPNsense Live View
- `06-dcdiag.png` — `dcdiag /q` with no output
- `12-drives-direction.png` — mapped drives for a Direction user
- `16-access-denied.png` — AGDLP: access refused to another department's share
- `18-glpi-ldap-login.png` — GLPI login with an AD account
- `20-backup-success.png` — Windows Server Backup "Réussite" + NAS folder
- `21-restore.png` — restored file with its permissions
- `22-wazuh-agents.png` — all agents active
- `23-wazuh-lockout.png` — rule 60115 alert
- `24-wazuh-87702.png` — repeated blocks detected from the firewall syslog
- `26-glpi-https-dmz.png` — GLPI published over HTTPS through the DMZ proxy
- `opnsense-rules.png`, `ad-ous-groups.png`, `omv-raid1-clean.png`

Before uploading, hide anything personal (e-mail addresses, real names outside the lab, license keys).
