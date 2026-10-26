# PKI (AD CS) — v1.1

Single-tier **Enterprise root CA** `LAB-ROOT-CA` on a dedicated server, CA01 (10.2.0.74).

| Item | Value |
|---|---|
| Key / hash / validity | RSA 4096 · SHA-256 · 10 years |
| CRL / delta CRL | 1 week / 1 day, published in AD (LDAP) and over HTTP (`http://ca01.lab.local/CertEnroll/`) |
| Templates published | Kerberos Authentication (domain controller → LDAPS) · LAB-Serveur-Web (duplicate of Web Server, 1 year, exportable key) |
| Auto-enrollment | GPO `GPO-DOMAINE-PKI-Inscription-Auto` linked at the domain root |
| Certificates issued | SRV-AD (Kerberos/LDAPS) · glpi.lab.local · fw01.lab.local · siem01.lab.local |
| Non-Windows devices | key generated on the device, CSR signed with `certreq`, key never leaves the device |
| Monitoring | CA auditing + Wazuh agent + custom rules ([`../wazuh/local_rules-adcs.xml`](../wazuh/local_rules-adcs.xml)) |
| Backup | `certutil -backup` + registry config + CAPolicy.inf → NAS ([`../../scripts/windows/CA01-backup.cmd`](../../scripts/windows/CA01-backup.cmd)) |

**Production design:** two tiers — an offline root (often HSM-protected) signing an online issuing CA — plus an OCSP responder. A single tier on a dedicated server is acceptable for a small environment. Never install a CA on a domain controller.

The CA's private key and its backup (`.p12`) are **not** in this repository.
