#!/bin/bash

BACKUP_DIR="/tmp/backup/postgresql"
DATE=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$DATE.sql.gz"
RETENTION_DAYS=7

EMAIL_SUBJECT="PostgreSQL Backup Successful: $DB_NAME"
BODY_MESSAGE="The daily backup for database $DB_NAME has completed successfully. The file is attached."


mkdir -p $BACKUP_DIR

if pg_dump -U "$DB_USER" -h "$DB_HOST" "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    echo "Backup created successfully: $BACKUP_FILE"
else
    echo "Backup failed for database $DB_NAME."
    exit 1
fi

echo "$BODY_MESSAGE" | msmtp -a default "$RECIPIENT_EMAIL" < "$BACKUP_FILE"
if [ $? -eq 0 ]; then
    echo "Backup file sent successfully to $RECIPIENT_EMAIL"
else
    echo "Failed to send email with attachment."
fi

find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -delete
echo "Old backups removed."
