#!/bin/bash
# Make a Debian/Ubuntu server trust LAB-ROOT-CA (the CA serves its certificate in DER, Linux expects PEM).
# Not usable from the DMZ (PROXY01): the DMZ cannot reach CA01 — copy the PEM file by hand there.
set -e
cd /tmp
wget -q http://ca01.lab.local/CertEnroll/CA01.lab.local_LAB-ROOT-CA.crt
openssl x509 -inform DER -in CA01.lab.local_LAB-ROOT-CA.crt -out LAB-ROOT-CA.crt
sudo cp LAB-ROOT-CA.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
# check: the domain controller's LDAPS certificate must verify
openssl s_client -connect srv-ad.lab.local:636 -brief </dev/null 2>&1 | grep -E "Verification|Protocol"
