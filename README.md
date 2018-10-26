# FoinBack
Full-Backup solution on the fly
```sh
Bearbeiten
$ vi /etc/foinback.sh

Unix-Dateirechte
$ chmod +x /etc/foinback.sh

Test
$ /etc/foinback.sh
```
---
### SSMTP & MailUtils
Installtion
```sh
$ sudo apt-get install ssmtp
$ sudo apt-get install mailutils
```
Konfiguration
```sh
$ sudo vi /etc/ssmtp/ssmtp.conf

root=BEISPIEL@mailadresse.de
mailhub=smtp.mailadresse.de:587
hostname=BEISPIEL@mailadresse.de
UseSTARTTLS=YES
AuthUser=BEISPIEL
AuthPass=GEHEIM
```
---
### Crontab

Crontab einrichten (Backup alle 7 Tage)

```sh
$ crontab -e

0 5 1 * * /etc/foinback.sh > /dev/null
0 5 8 * * /etc/foinback.sh > /dev/null
0 5 15 * * /etc/foinback.sh > /dev/null
0 5 22 * * /etc/foinback.sh > /dev/null
0 5 29 * * /etc/foinback.sh > /dev/null
```
