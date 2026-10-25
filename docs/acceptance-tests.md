# Acceptance tests

Run after every rebuild. Each test has an expected result; screenshots of the proofs go in [`screenshots/`](screenshots/).

Track B (Cisco hardware): run the network tests of chapter 11B of the guide first; tests 3–5 then apply to the router ACLs instead of OPNsense.

| # | Area | Test | Expected | Result |
|---|---|---|---|---|
| 1 | Network | CLT01 gets an address | 10.2.0.10–.60, DHCP server 10.2.0.70 (relay) |  |
| 2 | Network | CLT01 pings servers by name | srv-ad, fs01, lnx01 answer |  |
| 3 | Security | CLT01 → 10.2.0.97 / 10.2.0.1 GUI | blocked (logged in Live View) |  |
| 4 | Security | CLT01 → SIEM01 :1514 / :443 | True / False |  |
| 5 | Admin | Host PC opens OPNsense, Wazuh, OMV | all three load |  |
| 6 | AD | dcdiag /q on SRV-AD | no output |  |
| 7 | Time | w32tm /query /status on SRV-AD | source pool.ntp.org, stratum 2–4 |  |
| 8 | DNS | nslookup 10.2.0.72 10.2.0.70 | lnx01.lab.local |  |
| 9 | Policy | net accounts | 12 / 5 / 5 / 15 / 15 |  |
| 10 | Policy | reset a password to 9 characters | refused |  |
| 11 | Policy | 5 wrong passwords on test.recette | 6th attempt: error 1909, account locked |  |
| 12 | GPO | logon as Compta / Direction / Info | drives P F · P D F V T · P I |  |
| 13 | GPO | wallpaper | applied |  |
| 14 | GPO | cmd as business user / Informatique | blocked / allowed (gpresult /r) |  |
| 15 | Hours | business logon outside Mon–Fri 08–17 | refused (Windows and GLPI) |  |
| 16 | AGDLP | emma.laurent → Direction | accès refusé |  |
| 17 | AGDLP | alice.martin → Comptabilite, create a file | read OK, write refused |  |
| 18 | GLPI | login AD account (maxime.roux) | OK, profiles Technician + Self-Service |  |
| 19 | SSH | ssh tech1@10.2.0.72 / without key / from CLT01 | OK / Permission denied (publickey) / blocked |  |
| 20 | Backup | last job of SRV-AD, FS01; LNX01 log | Réussite · “sauvegarde OK” |  |
| 21 | Restore | deleted test file restored | file back with ACLs |  |
| 22 | SIEM | agents list | all active, same version |  |
| 23 | SIEM | lockout test | rule 60115 on SRV-AD |  |
| 24 | SIEM | fast ping from CLT01 to 10.2.0.97 | rule 87702, srcip 10.2.0.10 |  |
| 25 | DMZ | PROXY01 → 10.2.0.70:445 and 10.2.0.72:22 | BLOCKED |  |
| 26 | DMZ | https://192.168.10.136 from the host | GLPI login page through Nginx |  |
| 27 | DMZ | curl -kI https://localhost on PROXY01 | Server: nginx (no version) |  |
