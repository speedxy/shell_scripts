#!/bin/bash
USER="user"
REMOTE_MYSQL_PASS="pass"
REM_DIR="remote_directory/"
LOC_DIR="local_directory/"
REMOTE_MYSQL_DB="remote_db"
LOCAL_MYSQL_DB="local_db"

LOCAL_MYSQL_USER=""
LOCAL_MYSQL_PASS=""

# CMS (typo3-6 | pmcms | wordpress | shopware | veyton | xt:commerce)
CMS="typo3-6"

# ===

SCRIPT_DIR=$(dirname "$0")

REMOTE_SSH_USER="$USER"
REMOTE_DIR="/var/www/${REMOTE_SSH_USER}/html/${REM_DIR}"
REMOTE_HOST="pm-server.de"
REMOTE_MYSQL_HOST="localhost"
REMOTE_MYSQL_USER="$REMOTE_SSH_USER"

LOCAL_MYSQL_HOST="localhost"
LOCAL_DIR="$SCRIPT_DIR/../$LOC_DIR"

$SCRIPT_DIR/download.sh $REMOTE_HOST $REMOTE_SSH_USER $REMOTE_MYSQL_HOST $REMOTE_MYSQL_USER $REMOTE_MYSQL_PASS $REMOTE_MYSQL_DB $REMOTE_DIR $LOCAL_MYSQL_HOST $LOCAL_MYSQL_USER $LOCAL_MYSQL_PASS $LOCAL_MYSQL_DB $LOCAL_DIR $CMS
