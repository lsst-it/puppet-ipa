#!/bin/sh
#
# Script to work around the fact that ipa-backup always adds timestamps to the
# backups. This is not intended to be used standalone, but from Puppet-managed
# cronjobs.
#
# NOTE: this script will destroy old timestamped backup directories if timestamp
# is set to false.

TYPE=$1
TIMESTAMP=$2

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

BASEDIR="/var/lib/ipa/backup"

if [ "$TYPE" = "full" ]; then
    BACKUP_COMMAND="ipa-backup"
elif [ "$TYPE" = "data" ]; then
    BACKUP_COMMAND="ipa-backup --online --data"
else
    echo "ERROR: unknown backup type $TYPE"
    exit 1
fi

if [ "$TIMESTAMP" = "true" ]; then
    # ipa-backup outputs only to stderr so we can't simply redirect to /dev/null
    # and expect cron to email us about errors.
    $BACKUP_COMMAND 2> /dev/null || echo "ERROR: $BACKUP_COMMAND failed!"

elif [ "$TIMESTAMP" = "false" ]; then
    # Remove all old backups
    find $BASEDIR -mindepth 1 -maxdepth 1 -type d -name "ipa-${TYPE}*" -exec rm -rf {} \;

    # Take the backup (and report only failures)
    $BACKUP_COMMAND 2> /dev/null || echo "ERROR: $BACKUP_COMMAND failed!"

    # Get rid of the timestamp
    find "$BASEDIR" -mindepth 1 -maxdepth 1 -type d -name "ipa-${TYPE}*" -exec mv {} "${BASEDIR}/ipa-${TYPE}" \;
else
    echo "ERROR: $TIMESTAMP is not valid value for timestamp!"
    exit 1
fi
