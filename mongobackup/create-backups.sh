#!/bin/bash
#
# Creates a new mongodb backups using mongo tools
#
# Usage: create-backups.sh backupName
# E.g.:  create-backups.sh  1491483133533
#
# Recommended backupName: date +%s%N | cut -b1-13
#
cd ${BASH_SOURCE%/*}
set -e
if [ "$#" -ne 1 ]; then
cat << EOF
Creates a new mongodb backups using mongo tools

Usage: create-backups.sh backupName
E.g.:  create-backups.sh  1491483133533

Recommended backupName: $(date +%s%N | cut -b1-13)
EOF
    exit
fi

_BACKUP_NAME=$1

source ./settings.sh

###############################################################################

_TARGET_FOLDER_NAME='/tmp/'$_BACKUP_NAME
_DATABASES_TO_BACKUP="/tmp/databases_to_backup"

echo "creating backup $_BACKUP_NAME for all databases..."
mkdir $_TARGET_FOLDER_NAME
mongo --port 27017 -u "adminUser" -p "YEURhcq63BhAQBB7" --authenticationDatabase "admin" < ./listDbs.js | tail -n +4 | head -n -1 | awk '{print $1}' > $_DATABASES_TO_BACKUP

for db_to_backup in `cat $_DATABASES_TO_BACKUP`
do
  echo " * creating backup for: $db_to_backup"
  mongodump --port 27017 -u "adminUser" -p "YEURhcq63BhAQBB7" --authenticationDatabase "admin" -d $db_to_backup -o $_TARGET_FOLDER_NAME -v
done

echo ""
echo "pushing backup $_BACKUP_NAME to S3 bucket..."
aws s3 cp $_TARGET_FOLDER_NAME $_S3_BACKUP_BUCKET'/'$_BACKUP_NAME --recursive

rm $_DATABASES_TO_BACKUP
rm -r $_TARGET_FOLDER_NAME

exit $?