#!/bin/bash

#  ______    _       ____             _    
# |  ____|  (_)     |  _ \           | |   
# | |__ ___  _ _ __ | |_) | __ _  ___| | __
# |  __/ _ \| | '_ \|  _ < / _` |/ __| |/ /
# | | | (_) | | | | | |_) | (_| | (__|   < 
# |_|  \___/|_|_| |_|____/ \__,_|\___|_|\_\
# FoinBack - Full-Backup solution on the fly v1.0
# https://github.com/FoinB/FoinBack

### Optionen ###
HOSTNAME=localhost			## Name des Servers
BACKUPALTER=30				## loescht Backups die aelter als X Tage sind
NAS_IP=192.168.1.1			## IP Adresse des NAS-Servers
NAS_PFAD=Backup/localhost		## Pfad auf dem NAS-Server
NAS_USER=backup				## NAS User
NAS_PASSWORD=backuppw			## NAS Passwort
CIFS_VERS=2.0				## CIFS Version
EMAILEMPFAENGER=mail@backup.de		## E-Mail Empfaenger - E-Mail Client muss installiert sein  (z.B. ssmtp & mailutils). Alternativ als Empfaenger "root" eintragen

### Datum erfassen ###
DATUM="$(date +%Y-%m-%d)"

### Startzeit erfassen ###
STARTZEIT="$(date +%H:%M:%S)"

### Backupverzeichnis anlegen ###
mkdir -p /mnt/nas

### Test ob Backupverzeichnis existiert und Mail an Admin bei fehlschlagen ###
if [ ! -d "/mnt/nas" ]; then
 
mail -s "Backupverzeichnis nicht vorhanden!" "${EMAILEMPFAENGER}" <<EOM
Hallo Admin,
das Backup am ${DATUM} konnte nicht erstellt werden. Das Verzeichnis "/mnt/nas" wurde nicht gefunden und konnte auch nicht angelegt werden.
EOM
 
 . exit 1
fi

### Freigabe einbinden ###
mount -t cifs -o user=${NAS_USER},password=${NAS_PASSWORD},rw,file_mode=0777,dir_mode=0777,vers=${CIFS_VERS} //${NAS_IP}/${NAS_PFAD} /mnt/nas

### Filename definieren ###
FILENAME="${HOSTNAME}-${DATUM}.img.gz"

### Backup erstellen ###
dd if=/dev/mmcblk0 | gzip > /mnt/nas/${FILENAME}

### Endzeit erfassen ###
ENDZEIT=$(date +%H:%M:%S)

### Abfragen ob das Backup erfolgreich war ##
if [ $? -ne 0 ]; then

mail -s "Backup (${HOSTNAME}) war fehlerhaft!" "${EMAILEMPFAENGER}"  <<EOM
Hallo Admin,
das Backup ${filename} am ${DATUM} wurde mit Fehler(n) beendet.
EOM
 
else
 
### Dateigroesse ermitteln ###
GROESSE="$(du -sh /mnt/nas/${filename})"
 
 
mail -s "Backup (${HOSTNAME}) war erfolgreich" "${EMAILEMPFAENGER}"  <<EOM
Hallo Admin,
das Backup wurde erfolgreich erstellt.
 
----------------Details--------------------
Name:           ${FILENAME}
Datum:          ${DATUM}
Startzeit:      ${STARTZEIT}
Endzeit:        ${ENDZEIT}
Dateigroesse:   ${GROESSE}
EOM
 
fi

### Alte Sicherung loeschen ###
find "/mnt/nas" -type f -mtime +"${BACKUPALTER}" -delete

### Freigabe auswerfen ###
umount /mnt/nas
