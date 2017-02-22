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
# - Bereinigen der Datenbank vor Import?
#####

# Prüfe Parameter
if [ $# = 0 ] ; then # Keine Argumente: Starte interaktiven Modus
    echo "Usage: $0 remote_host remote_ssh_user remote_mysql_host remote_mysql_user remote_mysql_pass remote_mysql_db remote_dir local_mysql_host local_mysql_user local_mysql_pass local_mysql_db local_dir cms mysqldump_conf"
    echo "cms (wordpress|pmcms|typo3-6)"
    echo "mysqldump_conf (--skip-set-charset)"
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
    LOCAL_DIR=$(realpath "${12}")

    CMS=${13}

    MYSQLDUMP_CONF=${14}
fi


# Parameter-Zusammenfassung (debugging)
echo "Synchronisiere Dateisystem: $REMOTE_SSH_USER@$REMOTE_HOST:$REMOTE_DIR => $LOCAL_DIR"
echo "Synchronisiere Datenbank: $REMOTE_MYSQL_USER@$REMOTE_MYSQL_HOST.$REMOTE_MYSQL_DB on $REMOTE_HOST => $LOCAL_MYSQL_USER@$LOCAL_MYSQL_HOST.$LOCAL_MYSQL_DB on localhost"

# Synchronisiere Dateien
echo "Synchronisiere Dateien..."
echo "rsync -rltchvzP -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" --delete ${REMOTE_SSH_USER}@${REMOTE_HOST}:${REMOTE_DIR} \"${LOCAL_DIR}/\""
echo "Bitte SSH-Kennwort eingeben:"
rsync -rltchvzP -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" --delete ${REMOTE_SSH_USER}@${REMOTE_HOST}:${REMOTE_DIR} "${LOCAL_DIR}/"
echo "Fertig."

# Synchronisiere Datenbank
echo "Synchronisiere Datenbank..."
echo "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet ${REMOTE_SSH_USER}@${REMOTE_HOST} \"mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p***** ${REMOTE_MYSQL_DB}\" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p***** $LOCAL_MYSQL_DB"
echo "Bitte SSH-Kennwort erneut eingeben:"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet ${REMOTE_SSH_USER}@${REMOTE_HOST} "mysqldump -h${REMOTE_MYSQL_HOST} -u${REMOTE_MYSQL_USER} -p${REMOTE_MYSQL_PASS} {$MYSQLDUMP_CONF} ${REMOTE_MYSQL_DB}" | mysql -h${LOCAL_MYSQL_HOST} -u$LOCAL_MYSQL_USER -p$LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB
echo "Fertig."

case "$CMS" in
    "wordpress") 
    # WordPress
    sed -i "s/'DB_NAME', '$REMOTE_MYSQL_DB'/'DB_NAME', '$LOCAL_MYSQL_DB'/g" $LOCAL_DIR/wp-config.php
    sed -i "s/'DB_USER', '$REMOTE_MYSQL_USER'/'DB_USER', '$LOCAL_MYSQL_USER'/g" $LOCAL_DIR/wp-config.php
    sed -i "s/'DB_PASSWORD', '$REMOTE_MYSQL_PASS'/'DB_PASSWORD', '$LOCAL_MYSQL_PASS'/g" $LOCAL_DIR/wp-config.php
    sed -i "s/'DB_HOST', '$REMOTE_MYSQL_HOST'/'DB_HOST', '$LOCAL_MYSQL_HOST'/g" $LOCAL_DIR/wp-config.php
    ;;
    "pmcms")
    # PM CMS
    sed -i "s/host = \"$REMOTE_MYSQL_HOST\"/host = \"$LOCAL_MYSQL_HOST\"/g" $LOCAL_DIR/ini/host.ini
    sed -i "s/database = \"$REMOTE_MYSQL_DB\"/database = \"$LOCAL_MYSQL_DB\"/g" $LOCAL_DIR/ini/host.ini
    sed -i "s/username = \"$REMOTE_MYSQL_USER\"/username = \"$LOCAL_MYSQL_USER\"/g" $LOCAL_DIR/ini/host.ini
    sed -i "s/password = \"$REMOTE_MYSQL_PASS\"/password = \"$LOCAL_MYSQL_PASS\"/g" $LOCAL_DIR/ini/host.ini
    ;;
    "typo3-6")
    # TYPO3
    sed -i "s/'password' => '$REMOTE_MYSQL_PASS'/'password' => '$LOCAL_MYSQL_PASS'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
    sed -i "s/'username' => '$REMOTE_MYSQL_USER'/'username' => '$LOCAL_MYSQL_USER'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
    sed -i "s/'database' => '$REMOTE_MYSQL_DB'/'database' => '$LOCAL_MYSQL_DB'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
    sed -i "s/'host' => '$REMOTE_MYSQL_HOST'/'host' => '$LOCAL_MYSQL_HOST'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
    rm -r $LOCAL_DIR/typo3temp
    ;;
    "shopware")
    # Shopware
    sed -i "s/'password' => '$REMOTE_MYSQL_PASS'/'password' => '$LOCAL_MYSQL_PASS'/" $LOCAL_DIR/config.php
    sed -i "s/'username' => '$REMOTE_MYSQL_USER'/'username' => '$LOCAL_MYSQL_USER'/" $LOCAL_DIR/config.php
    sed -i "s/'dbname' => '$REMOTE_MYSQL_DB'/'dbname' => '$LOCAL_MYSQL_DB'/" $LOCAL_DIR/config.php
    sed -i "s/'host' => '$REMOTE_MYSQL_HOST'/'host' => '$LOCAL_MYSQL_HOST'/" $LOCAL_DIR/config.php
    chmod u+x $LOCAL_DIR/var/cache/clear_cache.sh
    chmod u+x $LOCAL_DIR/bin/console
    $LOCAL_DIR/var/cache/clear_cache.sh
    ;;
    "veyton")
    # VEYTON
    sed -i "s/define('_SYSTEM_DATABASE_PWD', '$REMOTE_MYSQL_PASS');/define('_SYSTEM_DATABASE_PWD', '$LOCAL_MYSQL_PASS');/" $LOCAL_DIR/conf/config.php
    sed -i "s/define('_SYSTEM_DATABASE_USER', '$REMOTE_MYSQL_USER');/define('_SYSTEM_DATABASE_USER', '$LOCAL_MYSQL_USER');/" $LOCAL_DIR/conf/config.php
    sed -i "s/define('_SYSTEM_DATABASE_DATABASE', '$REMOTE_MYSQL_DB');/define('_SYSTEM_DATABASE_DATABASE', '$LOCAL_MYSQL_DB');/" $LOCAL_DIR/conf/config.php
    sed -i "s/define('_SYSTEM_DATABASE_HOST', '$REMOTE_MYSQL_HOST');/define('_SYSTEM_DATABASE_HOST', '$LOCAL_MYSQL_HOST');/" $LOCAL_DIR/conf/config.php
    ;;
    "xt:commerce")
    # xt:commerce
    sed -i "s/define('DB_SERVER_PASSWORD', '$REMOTE_MYSQL_PASS');/define('DB_SERVER_PASSWORD', '$LOCAL_MYSQL_PASS');/" $LOCAL_DIR/admin/includes/configure.php
    sed -i "s/define('DB_SERVER_USERNAME', '$REMOTE_MYSQL_USER');/define('DB_SERVER_USERNAME', '$LOCAL_MYSQL_USER');/" $LOCAL_DIR/admin/includes/configure.php
    sed -i "s/define('DB_DATABASE', '$REMOTE_MYSQL_DB');/define('DB_DATABASE', '$LOCAL_MYSQL_DB');/" $LOCAL_DIR/admin/includes/configure.php
    sed -i "s/define('DB_SERVER', '$REMOTE_MYSQL_HOST');/define('DB_SERVER', '$LOCAL_MYSQL_HOST');/" $LOCAL_DIR/admin/includes/configure.php
    sed -i "s/define('DB_SERVER_PASSWORD', '$REMOTE_MYSQL_PASS');/define('DB_SERVER_PASSWORD', '$LOCAL_MYSQL_PASS');/" $LOCAL_DIR/includes/configure.php
    sed -i "s/define('DB_SERVER_USERNAME', '$REMOTE_MYSQL_USER');/define('DB_SERVER_USERNAME', '$LOCAL_MYSQL_USER');/" $LOCAL_DIR/includes/configure.php
    sed -i "s/define('DB_DATABASE', '$REMOTE_MYSQL_DB');/define('DB_DATABASE', '$LOCAL_MYSQL_DB');/" $LOCAL_DIR/includes/configure.php
    sed -i "s/define('DB_SERVER', '$REMOTE_MYSQL_HOST');/define('DB_SERVER', '$LOCAL_MYSQL_HOST');/" $LOCAL_DIR/includes/configure.php
    sed -i "s@define('DIR_FS_DOCUMENT_ROOT', '.*');@define('DIR_FS_DOCUMENT_ROOT', '$LOCAL_DIR/');@" $LOCAL_DIR/includes/configure.php
    sed -i "s@define('DIR_FS_CATALOG', '.*');@define('DIR_FS_CATALOG', '$LOCAL_DIR/');@" $LOCAL_DIR/includes/configure.php
    ;;
esac
