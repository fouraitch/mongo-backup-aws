#!/usr/bin/env bash

NEWEST_BACKUP_FILE=$(ls -t /backup | head -1)
STORAGE=${S3_BUCKET}
MIGRATE_CMD="aws s3 cp /${NEWEST_BACKUP_FILE}.zip s3://${STORAGE}/${NEWEST_BACKUP_FILE}.zip"

if [[ -n "${NEWEST_BACKUP_FILE}" ]]; then
    echo "=> Compressing ${NEWEST_BACKUP_FILE} file"
    echo "=> The latest mongo dump is: ${NEWEST_BACKUP_FILE}"
    cd /backup
    zip -r /"${NEWEST_BACKUP_FILE}.zip" ./"${NEWEST_BACKUP_FILE}"
    echo "=> Compression done!"
    cd /
    echo "=> Migrating to AWS S3 Bucket..."
    if ${MIGRATE_CMD}; then
        echo "=> Migration done!"
    else
        echo "Migration Failed"
        exit 1
    fi
    echo "=> Removing zipped file from container"
    rm -f /"${NEWEST_BACKUP_FILE}.zip"
    echo "=> Removed!"
    echo "=> Removing backup file from /backup directory"
    rm -rf /backup/"${NEWEST_BACKUP_FILE}"
    echo "=> Removed!"
else
    echo "=> No backup file found.."
fi