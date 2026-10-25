@echo off
rem FS01: export share definitions and NTFS ACLs into D: so they are included in the D: backup
mkdir D:\CONFIG
reg export "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares" D:\CONFIG\partages.reg /y
icacls D:\PARTAGES /save D:\CONFIG\acl-partages.txt /t /c
