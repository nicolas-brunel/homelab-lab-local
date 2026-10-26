# Service configuration files

| File | Server | Purpose |
|---|---|---|
| [`glpi/glpi.conf`](glpi/glpi.conf) | LNX01 | Apache virtual host — document root is `glpi/public` |
| [`glpi/downstream.php`](glpi/downstream.php), [`glpi/local_define.php`](glpi/local_define.php) | LNX01 | move GLPI configuration and data outside the web root (`/etc/glpi`, `/var/lib/glpi`) |
| [`nginx/glpi`](nginx/glpi) | PROXY01 (DMZ) | TLS reverse proxy to GLPI with a certificate from LAB-ROOT-CA, HTTP → HTTPS redirect, `server_tokens off` |
| [`wazuh/ossec-remote-syslog.xml`](wazuh/ossec-remote-syslog.xml) | SIEM01 | receive firewall / router syslog on UDP 514 |
| [`ssh/10-novatech.conf`](ssh/10-novatech.conf) | LNX01 | SSH by key only, no root login |
| [`wazuh/local_rules-adcs.xml`](wazuh/local_rules-adcs.xml) | SIEM01 | custom rules for AD CS events (CA01), MITRE T1649 |
| [`pki/CAPolicy.inf`](pki/CAPolicy.inf) · [`pki/README.md`](pki/README.md) | CA01 | CA creation rules · PKI design summary |
