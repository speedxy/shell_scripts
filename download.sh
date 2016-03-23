#!/bin/bash
# Eike Swat <swat@parrot-media.de>
# Dieses Script lädt von einem entfernten Rechner per SSH ein angegebenes Verzeichnis rekursiv per rsync herunter unter Aussparung von bereits vorhandenen Dateien
# Zudem wird per SSH getunnelt die zugehörige MySQL-Datenbank übertragen und lokal eingespielt

# Variablen initialisieren (Remote)
SERVER=
REMOTE_MYSQL_USER=
REMOTE_MYSQL_PASS=
REMOTE_MYSQL_DB=
REMOTE_MYSQL_HOST=
REMOTE_DIR=/var/www/.../.
SSH_USER=
SSH_PASS=

# Variablen initialisieren (Local)
LOCAL_MYSQL_USER=
LOCAL_MYSQL_PASS=
LOCAL_MYSQL_DB=
LOCAL_MYSQL_HOST=
LOCAL_DIR=/var/www/.../.
LOCAL_USER=
LOCAL_GROUP=

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
rsync -chavzP --delete --stats ${SSH_USER}@${SERVER}:${REMOTE_DIR} ${LOCAL_DIR}
echo "Fertig."

# Setze Besitzer und Gruppe
echo "Setze lokale Berechtigungen..."
chown -R $LOCAL_USER:$LOCAL_GROUP $LOCAL_DIR
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
ssh ${SSH_USER}@${SERVER} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."
