#!/bin/bash
#
# Runs the mongo backup job, which
#  * creates mongodb backups using mongo tools
#  * removes old Mongo backups without deleting the latest X backups
#
# Usage: run-mongo-backup-job.sh numberOfBackupsToKeep backupName
# E.g.:  run-mongo-backup-job.sh 3 1491483133533
#
# Recommended backupName: date +%s%N | cut -b1-13
#
cd ${BASH_SOURCE%/*}
set -e

if [ "$#" -ne 2 ]; then
cat << EOF
Runs the mongo backup job, which
 * creates mongodb backups using mongo tools
 * removes old mongodb backups without deleting the latest X backups

Usage: run-mongo-backup-job.sh numberOfBackupsToKeep backupName
E.g.:  run-mongo-backup-job.sh 3 1491483133533

Recommended backupName: date +%s%N | cut -b1-13
EOF
    exit
fi

_NUMBER_OF_BACKUPS_TO_KEEP=$1
_BACKUP_NAME=$2

###############################################################################

echo "starting mongodb backup..."
echo ""

/bin/bash ./create-backups.sh $_BACKUP_NAME
_EXIT_CREATE_BACKUP=$?
/bin/bash ./remove-old-backups.sh $_NUMBER_OF_BACKUPS_TO_KEEP
_EXIT_REMOVEOLD_BACKUPS=$?

_MESSAGE="[ERROR] Unknown error occured while MongoDB backup! [name=$_BACKUP_NAME, error=$?]"
if [ $_EXIT_CREATE_BACKUP -ne 0 ]; then
  _MESSAGE="[ERROR] Creation of MongoDB backup faild! [name=$_BACKUP_NAME, error=$?]"
elif [ $_EXIT_REMOVEOLD_BACKUPS -ne 0 ]; then
  _MESSAGE="[ERROR] Removal of old backups faild! [name=$_BACKUP_NAME, error=$?]"
elif [ $_EXIT_REMOVEOLD_BACKUPS -eq 0 ] && [ $_EXIT_CREATE_BACKUP -eq 0 ]; then
  _MESSAGE="[SUCCESS] MongoDB backup successfully finished! [name=$_BACKUP_NAME]"
fi
/bin/bash ./slackpost.sh $_MESSAGE

echo ""
echo "...finished mongodb backup"

exit $?