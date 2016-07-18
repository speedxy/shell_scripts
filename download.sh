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
# - Interaktiv Bedienung ermöglichen
# - Prüfen auf abschließenden Slash von Pfaden (Es muss ein Slash angegeben sein)
#####

# Prüfe Parameter
if [ $# = 0 ] ; then # Keine Argumente: Starte interaktiven Modus
    echo "Usage: $0 remote_host remote_ssh_user remote_mysql_host remote_mysql_user remote_mysql_pass remote_mysql_db remote_dir local_mysql_host local_mysql_user local_mysql_pass local_mysql_db local_dir"
    exit 65
  else # Alle Parameter übergeben
    # Variablen initialisieren (Remote)
    REMOTE_HOST=$1
    REMOTE_SSH_USER=$2
    REMOTE_MYSQL_HOST=$3
    REMOTE_MYSQL_USER=$4
    REMOTE_MYSQL_PASS=$5
    REMOTE_MYSQL_DB=$6
    REMOTE_DIR=$7

    # Variablen initialisieren (Local)
    LOCAL_MYSQL_HOST=$8
    LOCAL_MYSQL_USER=$9
    LOCAL_MYSQL_PASS=${10}
    LOCAL_MYSQL_DB=${11}
    LOCAL_DIR=${12}
fi

# Parameter-Zusammenfassung (debugging)
echo "Synchronisiere Dateisystem: $REMOTE_SSH_USER@$REMOTE_HOST:$REMOTE_DIR => $LOCAL_DIR"
echo "Synchronisiere Datenbank: $REMOTE_MYSQL_USER@$REMOTE_MYSQL_HOST.$REMOTE_MYSQL_DB => $LOCAL_MYSQL_USER@$LOCAL_MYSQL_HOST.$LOCAL_MYSQL_DB"

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
echo "Bitte SSH-Kennwort eingeben:"
rsync -rltchvzP -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --delete ${REMOTE_SSH_USER}@${REMOTE_HOST}:${REMOTE_DIR} ${LOCAL_DIR}
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
echo "Bitte SSH-Kennwort erneut eingeben:"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet ${REMOTE_SSH_USER}@${REMOTE_HOST} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."
