#!/bin/bash
USER="user"
REMOTE_MYSQL_PASS="pass"
REM_DIR="/remote_directory/"
LOC_DIR="/remote_directory/"
REMOTE_MYSQL_DB="remote_db"
LOCAL_MYSQL_DB="local_db"

LOCAL_MYSQL_USER=""
LOCAL_MYSQL_PASS=""

# ===

SCRIPT_DIR=$(dirname "$0")

REMOTE_SSH_USER="$USER"
REMOTE_DIR="/var/www/${REMOTE_SSH_USER}/html${REM_DIR}"
REMOTE_HOST="pm-server.de"
REMOTE_MYSQL_HOST="localhost"
REMOTE_MYSQL_USER="$REMOTE_SSH_USER"

LOCAL_MYSQL_HOST="localhost"
LOCAL_DIR="$SCRIPT_DIR/../$LOC_DIR"

$SCRIPT_DIR/download.sh $REMOTE_HOST $REMOTE_SSH_USER $REMOTE_MYSQL_HOST $REMOTE_MYSQL_USER $REMOTE_MYSQL_PASS $REMOTE_MYSQL_DB $REMOTE_DIR $LOCAL_DIR $CMS

# WordPress
#sed -i "s/'DB_NAME', '$REMOTE_MYSQL_DB'/'DB_NAME', '$LOCAL_MYSQL_DB'/g" $LOCAL_DIR/wp-config.php
#sed -i "s/'DB_USER', '$REMOTE_MYSQL_USER'/'DB_USER', '$LOCAL_MYSQL_USER'/g" $LOCAL_DIR/wp-config.php
#sed -i "s/'DB_PASSWORD', '$REMOTE_MYSQL_PASS'/'DB_PASSWORD', '$LOCAL_MYSQL_PASS'/g" $LOCAL_DIR/wp-config.php
#sed -i "s/'DB_HOST', '$REMOTE_MYSQL_HOST'/'DB_HOST', '$LOCAL_MYSQL_HOST'/g" $LOCAL_DIR/wp-config.php

# PM CMS
#sed -i "s/host = \"$REMOTE_MYSQL_HOST\"/host = \"$LOCAL_MYSQL_HOST\"/g" $LOCAL_DIR/ini/host.ini
#sed -i "s/database = \"$REMOTE_MYSQL_DB\"/database = \"$LOCAL_MYSQL_DB\"/g" $LOCAL_DIR/ini/host.ini
#sed -i "s/username = \"$REMOTE_MYSQL_USER\"/username = \"$LOCAL_MYSQL_USER\"/g" $LOCAL_DIR/ini/host.ini
#sed -i "s/password = \"$REMOTE_MYSQL_PASS\"/password = \"$LOCAL_MYSQL_PASS\"/g" $LOCAL_DIR/ini/host.ini

# TYPO3
#sed -i "s/'password' => '$REMOTE_MYSQL_PASS'/'password' => '$LOCAL_MYSQL_PASS'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
#sed -i "s/'username' => '$REMOTE_MYSQL_USER'/'username' => '$LOCAL_MYSQL_USER'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
#sed -i "s/'database' => '$REMOTE_MYSQL_DB'/'database' => '$LOCAL_MYSQL_DB'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
#sed -i "s/'host' => '$REMOTE_MYSQL_HOST'/'host' => '$LOCAL_MYSQL_HOST'/" $LOCAL_DIR/typo3conf/LocalConfiguration.php
