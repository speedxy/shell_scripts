#!/bin/bash

# Variablen initialisieren
SSH_USER=
SSH_PASS=
REMOTE_DIR=/var/www/.../.
LOCAL_DIR=/var/www/.../.

REMOTE_MYSQL_USER=
REMOTE_MYSQL_PASS=
REMOTE_MYSQL_DB=
REMOTE_MYSQL_HOST=

LOCAL_MYSQL_USER=
LOCAL_MYSQL_PASS=
LOCAL_MYSQL_DB=
LOCAL_MYSQL_HOST=

SERVER=

LOCAL_USER=
LOCAL_GROUP=

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
rsync -chavzP --delete --stats ${SSH_USER}@${SERVER}:$REMOTE_DIR $LOCAL_DIR
echo "Fertig."

# Setze Besitzer und Gruppe
echo "Setze lokale Berechtigungen..."
chown -R $LOCAL_USER:$LOCAL_GROUP $LOCAL_DIR
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
ssh ${SSH_USER}@${SERVER} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."
