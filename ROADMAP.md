# Roadmap

Next steps for the lab, focused on automation (Python and Ansible) and on the CCNA.

| # | Project | Skills | Status |
|---|---|---|---|
| 1 | Ansible playbook: harden LNX01, PROXY01 and SIEM01 (SSH by key, ufw, chrony to the DC) | Ansible inventory, roles, idempotence | planned |
| 2 | Ansible playbook: deploy the Wazuh agent on every Linux server | Ansible variables, handlers | planned |
| 3 | Ansible `cisco.ios`: back up SW-LAB and R-LAB configurations to the NAS with a date | network automation | planned |
| 4 | Python + Netmiko: collect `show ip interface brief` / `show interfaces trunk` and flag interfaces that are down | Python, SSH automation | planned |
| 5 | Python: automate part of the acceptance tests (ping, open / blocked ports) and print a report | Python sockets, reporting | planned |
| 6 | Build track B on real Cisco hardware | CCNA practice | planned |
| 7 | LDAPS for GLPI with AD Certificate Services | PKI, TLS | idea |
| 8 | Second domain controller (Server Core) | AD replication | idea |
| 9 | Off-site / versioned backups (3-2-1 rule) | backup strategy | idea |
