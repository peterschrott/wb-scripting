#!/bin/bash
#
# Removes old mongodb backups without deleting the latest X backups.
#
# Usage: remove-old-backups.sh numberOfBackupsToKeep
# E.g.:  remove-old-backups.sh 3
#
#
cd ${BASH_SOURCE%/*}
set -e
export PATH=/usr/local/bin/:$PATH

if [ "$#" -ne 1 ]; then
cat << EOF
Removes old mongodb backups without deleting the latest X backups.

Usage: remove-old-backups.sh numberOfBackupsToKeep
E.g.:  remove-old-backups.sh 3
EOF
    exit
fi

_NUMBER_OF_BACKUPS_TO_KEEP=$1

source ./settings.sh

###############################################################################

_BACKUP_NAMES_FILE="/tmp/backups_to_remove"

echo "removing all but $_NUMBER_OF_BACKUPS_TO_KEEP backups from S3 bucket..."

aws s3 ls s3://whizbag-technology-mongodb-backup | awk '{print $2}' | sort | head -n -$_NUMBER_OF_BACKUPS_TO_KEEP > $_BACKUP_NAMES_FILE

for backup in `cat $_BACKUP_NAMES_FILE`
do
  echo " * removing backup $backup"
  aws s3 rm --recursive $_S3_BACKUP_BUCKET'/'$backup
done

rm $_BACKUP_NAMES_FILE

exit $?