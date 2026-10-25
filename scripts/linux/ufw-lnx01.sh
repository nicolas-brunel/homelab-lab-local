#!/bin/bash
# Host firewall for LNX01: SSH from the admin network only, HTTP for GLPI
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.2.0.96/28 to any port 22 proto tcp
sudo ufw allow 80/tcp
sudo ufw enable
sudo ufw status verbose
sudo ss -tlnp            # MariaDB 3306 must listen on 127.0.0.1 only
