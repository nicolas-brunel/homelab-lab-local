@echo off
rem CA01: back up the CA (key + database + configuration) and copy it to the NAS
rem certutil asks for a password protecting the .p12: store it in the password manager
mkdir C:\CABackup
certutil -backup C:\CABackup
reg export HKLM\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration C:\CABackup\CertSvc-config.reg /y
copy /y C:\Windows\CAPolicy.inf C:\CABackup\
net use \\nas01\Sauvegardes /user:nas01\SVC-Backup *
if not exist \\nas01\Sauvegardes\CA01 mkdir \\nas01\Sauvegardes\CA01
robocopy C:\CABackup \\nas01\Sauvegardes\CA01 /E /R:2 /W:5
net use \\nas01\Sauvegardes /delete
