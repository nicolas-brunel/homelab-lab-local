# Scripts

| Script | Where | What it does |
|---|---|---|
| [`linux/backup-glpi.sh`](linux/backup-glpi.sh) | LNX01 (cron 22:00) | mounts the NAS share, dumps the GLPI database, archives GLPI files and configs (including `glpicrypt.key`), keeps 7 days, unmounts |
| [`linux/ufw-lnx01.sh`](linux/ufw-lnx01.sh) | LNX01 | host firewall: SSH from the admin network only, HTTP for GLPI |
| [`windows/New-LabUser.ps1`](windows/New-LabUser.ps1) | SRV-AD | create an AD user; the password is typed at run time, never stored |
| [`windows/FS01-export-shares-acl.cmd`](windows/FS01-export-shares-acl.cmd) | FS01 | export share definitions and NTFS ACLs into D: so the D: backup can rebuild them |
| [`windows/FS01-enable-file-sharing.ps1`](windows/FS01-enable-file-sharing.ps1) | FS01 | enable File and Printer Sharing firewall rules (language-independent) |
| [`windows/SRV-AD-time-source.cmd`](windows/SRV-AD-time-source.cmd) | SRV-AD | make the PDC emulator a reliable time source synced to pool.ntp.org |

Credentials are never written in scripts: the backup script reads a root-only credentials file (`/root/.smb-nas`, mode 600).
