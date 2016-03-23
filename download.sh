#!/bin/bash
# Eike Swat <swat@parrot-media.de>
# Dieses Script lädt von einem entfernten Rechner per SSH ein angegebenes Verzeichnis rekursiv per rsync herunter unter Aussparung von bereits vorhandenen Dateien
# Zudem wird per SSH getunnelt die zugehörige MySQL-Datenbank übertragen und lokal eingespielt

# Prüfe Parameter
if [ $# = 0 ]
  then # Keine Argumente: Starte interaktiven Modus
    echo "Usage: $0 remote_server remote_ssh_user remote_ssh_pass remote_mysql_host remote_mysql_user remote_mysql_pass remote_mysql_db remote_dir local_user local_group local_mysql_host local_mysql_user local_mysql_pass local_mysql_db local_dir"
    exit 65
    # @Todo
    #read -e -p "Remote Server: " WEB
    #read -e -p "Web-Passwort (FTP & Shell): " -e PASS
    #read -e -p "MySQL-Passwort: " -s MYSQL_PASS
    #read -e -p "Datenbank (usr_{$WEB}_X): " DATABASE
    ##sshpass -p '$PASS' ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $WEB@hostname.de 'ls html'
    #read -e -p "Verzeichnis: /var/www/$WEB/html/" -i "/var/www/$WEB/html/" HTDOCS
  else # Alle Parameter übergeben
    # Variablen initialisieren (Remote)
    REMOTE_SERVER=$1
    REMOTE_SSH_USER=$2
    REMOTE_SSH_PASS=$3
    REMOTE_MYSQL_HOST=$4
    REMOTE_MYSQL_USER=$5
    REMOTE_MYSQL_PASS=$6
    REMOTE_MYSQL_DB=$7
    REMOTE_DIR=$8
    
    # Variablen initialisieren (Local)
    LOCAL_USER=
    LOCAL_GROUP=
    LOCAL_MYSQL_HOST=
    LOCAL_MYSQL_USER=
    LOCAL_MYSQL_PASS=
    LOCAL_MYSQL_DB=
    LOCAL_DIR=/var/www/.../.
fi

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
rsync -chavzP --delete --stats ${REMOTE_SSH_USER}@${REMOTE_SERVER}:${REMOTE_DIR} ${LOCAL_DIR}
echo "Fertig."

# Setze Besitzer und Gruppe
echo "Setze lokale Berechtigungen..."
chown -R $LOCAL_USER:$LOCAL_GROUP $LOCAL_DIR
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
ssh ${REMOTE_SSH_USER}@${REMOTE_SERVER} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."
