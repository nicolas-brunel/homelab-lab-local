#!/bin/bash
# Nightly GLPI backup (LNX01) to the NAS — cron: 0 22 * * * /usr/local/sbin/backup-glpi.sh
# Credentials live in /root/.smb-nas (chmod 600): username=SVC-Backup / password=... / domain=nas01
set -e
DATE=$(date +%F_%H%M)
MNT=/mnt/nas
DEST=$MNT/LNX01
mkdir -p $MNT
mount -t cifs //10.2.0.73/Sauvegardes $MNT -o credentials=/root/.smb-nas,vers=3.0
mkdir -p $DEST
mysqldump --single-transaction glpi | gzip > $DEST/glpi-db_$DATE.sql.gz
tar czf $DEST/glpi-files_$DATE.tar.gz --exclude=/var/lib/glpi/_cache \
  --exclude=/var/lib/glpi/_sessions --exclude=/var/lib/glpi/_tmp \
  /var/www/html/glpi /etc/glpi /var/lib/glpi /etc/apache2/sites-available /etc/ssh/sshd_config.d
find $DEST -name "glpi-*" -mtime +7 -delete
umount $MNT
echo "$(date) sauvegarde OK" >> /var/log/backup-glpi.log
