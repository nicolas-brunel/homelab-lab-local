rem SRV-AD (PDC emulator): use the French NTP pool as reliable time source
w32tm /config /manualpeerlist:"0.fr.pool.ntp.org 1.fr.pool.ntp.org" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync
w32tm /query /status
