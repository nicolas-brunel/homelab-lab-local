# Screenshots — the lab running

Proof captures taken on the running lab (October 2026). Numbers in file names match the tests in [`../acceptance-tests.md`](../acceptance-tests.md).

> Windows, VMware and some web interfaces are from a **French-language installation**; all documentation is in English.

**Contents:** [Lab platform](#lab-platform) · [Network and firewall](#network-and-firewall) · [Active Directory and Group Policy](#active-directory-and-group-policy) · [File server and access control](#file-server-and-access-control) · [GLPI helpdesk](#glpi-helpdesk) · [SSH hardening and DMZ](#ssh-hardening-and-dmz) · [Backups and restore](#backups-and-restore) · [SIEM (Wazuh)](#siem-wazuh) · [PKI — v1.1](#pki--v11)

---

## Lab platform

**All 8 VMs running**, organised by zone in the VMware library.

![VMware library](vmware-library.png)

**Virtual networks.** VMnet1 is the ADMINISTRATION network (host-only, 10.2.0.96/28, VMware DHCP disabled: addresses come from the lab itself). VMnet8 (NAT) plays the role of the Internet for the firewall's WAN.

![VMware network editor](vmware-network-editor.png)

---

## Network and firewall

**OPNsense dashboard**: the five interfaces, one per zone (WAN, ADMINISTRATION, SERVEURS, UTILISATEURS, DMZ).

![OPNsense dashboard](opnsense-dashboard.png)

**User zone rules**, evaluated top to bottom: DHCP relay, a narrow exception for the Wazuh agent ports, block toward the admin network (logged), block toward the firewall itself (logged), then everything else allowed.

![OPNsense rules](opnsense-rules.png)

**Test 3 — the rules in action**: the workstation (10.2.0.10) tries to open the firewall's web interface on its own gateway (10.2.0.1:443) and is blocked by the rule "Bloque accès au pare-feu".

![Firewall block](03-firewall-block.png)

**Destination NAT**: HTTPS on the WAN address is forwarded to the reverse proxy in the DMZ (10.2.0.114), never directly to GLPI.

![OPNsense NAT](opnsense-nat.png)

**Test 1 — DHCP through the relay**: the workstation in the user zone gets 10.2.0.10 from **SRV-AD (10.2.0.70)**, a server in another zone, through the firewall's DHCP relay.

![CLT01 ipconfig](01-clt01-ipconfig.png)

The matching lease in the domain controller's DHCP scope:

![DHCP lease](dhcp-lease.png)

---

## Active Directory and Group Policy

**OU structure and AGDLP groups**: 5 global groups (who) and 9 domain local groups (what: one resource + one access level).

![AD structure](ad-structure.png)

**AGDLP nesting**: the domain local group for the shared folder contains the 5 global groups, never individual users.

![AGDLP group](ad-agdlp-group.png)

**Group Policy objects** and where they are linked (domain root, user OU, business OUs).

![GPO list](gpo-list.png)

**Test 9 — password and lockout policy** applied domain-wide: 12 characters minimum, history of 5, lockout after 5 attempts for 15 minutes.

![Password policy](09-password-policy.png)

**Test 12 — drive mapping with item-level targeting**: a Direction user gets P: (common), D: (Direction) and read access to F:, V:, T:. *Found and fixed during this run: the two-group targeting was joined with AND instead of OR, so F:, V: and T: were missing — see [troubleshooting](../../troubleshooting.md).*

![Drives for a Direction user](12-drives-direction.png)

**Test 14 — command prompt blocked** for business users by GPO.

![CMD blocked](14-cmd-blocked.png)

**Test 15 — logon hours**: business accounts are allowed Monday–Friday 08:00–17:00 only (capture taken on a Sunday).

![Logon hours denied](15-logon-hours-denied.png)

---

## File server and access control

**Test 16 — AGDLP in practice**: an IT user has no rights on the Direction share and gets "access denied". Permissions come only from group membership.

![Access denied](16-access-denied.png)

---

## GLPI helpdesk

**LDAP link to Active Directory**: the 5 connection tests pass (TCP, base DN, URI, bind, search).

![GLPI LDAP test](glpi-ldap-test.png)

**Test 18 — login with an AD account**: maxime.roux, authenticated against Active Directory, with the Technician profile.

![GLPI AD login](18-glpi-ldap-login.png)

**A closed ticket** with diagnosis (AGDLP check), solution and approval.

![GLPI ticket](glpi-ticket.png)

---

## SSH hardening and DMZ

**Test 19 — SSH by key only**: login works with the key; the same login without the key is refused (`Permission denied (publickey)`).

![SSH key only](19-ssh-key-only.png)

**Test 25 — DMZ isolation**, from the reverse proxy: GLPI on port 80 answers (the only allowed path), while SMB to the domain controller and SSH to the GLPI server are blocked.

![DMZ isolation](25-dmz-isolation.png)

**Test 26 — GLPI published over HTTPS**: reached on the firewall's WAN address, through Nginx in the DMZ (self-signed certificate in the lab, hence the browser warning).

![GLPI over HTTPS](26-glpi-https-dmz.png)

---

## Backups and restore

**NAS RAID 1**: two disks mirrored, state *clean*.

![RAID 1](omv-raid1.png)

**File system on the mirror**: mounted and monitored (about half used by one full-recovery copy of the domain controller — backup scope sized to the storage available).

![OMV file system](omv-filesystem.png)

**One folder per source** on the backup share.

![Backup folders](omv-backup-folders.png)

**Test 20 — backup success** on the domain controller. *The two earlier failures were diagnosed during this run (network → account → stored credentials) and fixed by re-entering the credentials in the backup schedule — see [troubleshooting](../../troubleshooting.md).*

![Backup success](20-backup-success.png)

**Test 21 — restore test**: a deleted file restored from the NAS backup to its original location, **with its permissions** (DL_FS_COMMUN_RW).

![Restore](21-restore.png)

---

## SIEM (Wazuh)

**Test 22 — agents**: 6 agents active (3 Windows, 3 Debian), all on the same version as the manager.

![Wazuh agents](22-wazuh-agents.png)

**Test 23 — account lockout detection**: 5 wrong passwords on a test account. Wazuh shows the logon failures on the file server (rule 60122) and the lockout on the domain controller one second later (rule 60115, level 9).

![Wazuh lockout](23-wazuh-lockout.png)

The test itself: five "wrong password" errors (1326), then "account locked" (1909).

![Lockout test](23b-lockout-runas.png)

**Test 24 — repeated firewall blocks**: the workstation sends fast pings to the admin network; the blocks logged by OPNsense reach Wazuh by syslog and trigger rule 87702 (level 10, same source blocked 18 times in 45 seconds).

![Wazuh 87702](24-wazuh-scan.png)

---

## PKI — v1.1

Internal certificate authority added to fix two weak points: LDAP in clear text and self-signed certificates. Details in chapter 14 of the guide.

**Before / after — GLPI ↔ Active Directory.** Before: LDAP on port 389, the bind password in clear text ([`glpi-ldap-test.png`](glpi-ldap-test.png)). After: **LDAPS on port 636**, encrypted.

![GLPI LDAPS](pki-ldaps-glpi.png)

**Before / after — GLPI over HTTPS.** Before: self-signed certificate, "Not secure" ([`26-glpi-https-dmz.png`](26-glpi-https-dmz.png)). After: certificate issued by **LAB-ROOT-CA**, padlock.

![GLPI trusted HTTPS](pki-glpi-https-trusted.png)

**Healthy PKI**: CA certificate, AIA and CRL/delta CRL published over LDAP and HTTP, all OK.

![pkiview](pki-pkiview.png)

**Domain machines trust the CA automatically** (Enterprise CA certificate published in AD).

![Root trusted](pki-root-trusted.png)

**Only the templates needed are published** (the CA starts with none): Kerberos Authentication for the domain controller, LAB-Serveur-Web for HTTPS.

![Templates](pki-templates.png)

**Auto-enrollment by GPO**, so machines request and renew their certificates on their own.

![Auto-enrollment GPO](pki-autoenroll-gpo.png)

**Issued certificates**: the domain controller (LAB\SRV-AD$) enrolled automatically.

![Issued certificates](pki-issued-certs.png)

**LDAPS on the domain controller**: SSL connection on port 636, 256-bit cipher.

![LDAPS ldp](pki-ldaps-ldp.png)

**Chain of trust** of the GLPI certificate: LAB-ROOT-CA → glpi.lab.local. The private key was generated on the proxy and never left it.

![Certificate chain](pki-cert-chain.png)

**OPNsense and Wazuh** web interfaces with certificates from the internal CA.

![OPNsense trusted](pki-opnsense-trusted.png)

![Wazuh trusted](pki-wazuh-trusted.png)

**Monitoring the CA**: CA auditing is off by default and Wazuh has no built-in rule for AD CS events, so custom rules were written (100200–100203, MITRE T1649). Test: restarting Certificate Services raises rule 100200 on agent CA01.

![Wazuh custom rule](pki-wazuh-custom-rule.png)
