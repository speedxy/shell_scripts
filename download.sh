#!/bin/bash
#####
# Eike Swat <swat@parrot-media.de>
# Dieses Script lädt von einem entfernten Rechner per SSH ein angegebenes Verzeichnis rekursiv per rsync herunter unter Aussparung von bereits vorhandenen Dateien
# Zudem wird per SSH getunnelt die zugehörige MySQL-Datenbank übertragen und lokal eingespielt
#####
# ToDo:
# - Berücksichtigung des CMS; z.B. Ignorieren von typo3temp bei TYPO3; Anpassen der CMS-Konfiguration
# - Automatische Bereinigung des Downloads
# - Interaktive Parameterermittlung
#####

# Prüfe Umgebung
PROGRAM="sshpass"
CONDITION=$(which $PROGRAM 2>/dev/null | grep -v "not found" | wc -l)
if [ $CONDITION -eq 0 ] ; then
  echo "$PROGRAM ist nicht installiert."
  exit
fi

# Prüfe Parameter
if [ $# = 0 ] ; then # Keine Argumente: Starte interaktiven Modus
    echo "Usage: $0 remote_host remote_ssh_user remote_ssh_pass remote_mysql_host remote_mysql_user remote_mysql_pass remote_mysql_db remote_dir local_mysql_host local_mysql_user local_mysql_pass local_mysql_db local_dir"
    exit 65
    # @Todo
    #read -e -p "Remote Host: " WEB
    #read -e -p "Web-Passwort (FTP & Shell): " -e PASS
    #read -e -p "MySQL-Passwort: " -s MYSQL_PASS
    #read -e -p "Datenbank (usr_{$WEB}_X): " DATABASE
    ##sshpass -p '$PASS' ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $WEB@hostname.de 'ls html'
    #read -e -p "Verzeichnis: /var/www/$WEB/html/" -i "/var/www/$WEB/html/" HTDOCS
  else # Alle Parameter übergeben
    # Variablen initialisieren (Remote)
    REMOTE_HOST=$1
    REMOTE_SSH_USER=$2
    REMOTE_SSH_PASS=$3
    REMOTE_MYSQL_HOST=$4
    REMOTE_MYSQL_USER=$5
    REMOTE_MYSQL_PASS=$6
    REMOTE_MYSQL_DB=$7
    REMOTE_DIR=$8

    # Variablen initialisieren (Local)
    LOCAL_MYSQL_HOST=$9
    LOCAL_MYSQL_USER=${10}
    LOCAL_MYSQL_PASS=${11}
    LOCAL_MYSQL_DB=${12}
    LOCAL_DIR=${13}
fi

# Parameter-Zusammenfassung (debugging)
echo "Synchronisiere Dateisystem: $REMOTE_SSH_USER@$REMOTE_HOST:$REMOTE_DIR => $LOCAL_DIR"
echo "Synchronisiere Datenbank: $REMOTE_MYSQL_USER@$REMOTE_MYSQL_HOST.$REMOTE_MYSQL_DB => $LOCAL_MYSQL_USER@$LOCAL_MYSQL_HOST.$LOCAL_MYSQL_DB"

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
sshpass -p "${REMOTE_SSH_PASS}" rsync -rltchvzP --delete --stats ${REMOTE_SSH_USER}@${REMOTE_HOST}:${REMOTE_DIR} ${LOCAL_DIR}
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
sshpass -p "${REMOTE_SSH_PASS}" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet ${REMOTE_SSH_USER}@${REMOTE_HOST} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
#sshpass -p "${REMOTE_SSH_PASS}" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${REMOTE_SSH_USER}@${REMOTE_HOST} "ls -al"
#ssh ${REMOTE_SSH_USER}@${REMOTE_HOST} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."
