#!/bin/bash
set -e

echo "========================================="
echo "Starting MongoDB backup: $(date)"
echo "========================================="

# Create timestamp for backup file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${TIMESTAMP}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
ARCHIVE_FILE="${BACKUP_DIR}.tar.gz"

# Create backup directory
mkdir -p ${BACKUP_DIR}

# Perform MongoDB dump
echo "Dumping MongoDB database..."
mongodump --uri="${MONGO_URI}" --out=${BACKUP_DIR}

if [ $? -eq 0 ]; then
    echo "MongoDB dump completed successfully"
else
    echo "MongoDB dump failed"
    exit 1
fi

# Compress the backup
echo "Compressing backup..."
tar -czf ${ARCHIVE_FILE} -C /tmp ${BACKUP_NAME}

if [ $? -eq 0 ]; then
    echo "Backup compressed successfully"
else
    echo "Backup compression failed"
    exit 1
fi

# Upload to S3
echo "Uploading to S3..."
S3_DESTINATION="s3://${S3_BUCKET}/${S3_PATH}/${BACKUP_NAME}.tar.gz"

if [ -n "$AWS_ENDPOINT_URL" ]; then
    aws s3 cp ${ARCHIVE_FILE} ${S3_DESTINATION} --endpoint-url ${AWS_ENDPOINT_URL}
else
    aws s3 cp ${ARCHIVE_FILE} ${S3_DESTINATION}
fi

if [ $? -eq 0 ]; then
    echo "Backup uploaded successfully to ${S3_DESTINATION}"
else
    echo "Backup upload failed"
    exit 1
fi

# Cleanup
echo "Cleaning up temporary files..."
rm -rf ${BACKUP_DIR}
rm -f ${ARCHIVE_FILE}

echo "========================================="
echo "Backup completed successfully: $(date)"
echo "========================================="
