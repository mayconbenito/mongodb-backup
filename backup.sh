#!/bin/bash
set -e

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="/tmp/mongo-backup-$DATE.tar.gz"

echo "[INFO] Starting MongoDB backup at $DATE"

# Dump MongoDB database
mongodump --uri="$MONGO_URI" --archive="$ARCHIVE" --gzip
echo "[INFO] Dump completed, uploading..."

# Upload to S3 or S3-compatible storage
if [ -n "$AWS_ENDPOINT_URL" ]; then
  aws --endpoint-url "$AWS_ENDPOINT_URL" s3 cp "$ARCHIVE" "s3://$S3_BUCKET/$S3_PATH/mongo-backup-$DATE.tar.gz"
else
  aws s3 cp "$ARCHIVE" "s3://$S3_BUCKET/$S3_PATH/mongo-backup-$DATE.tar.gz"
fi

echo "[INFO] Backup uploaded successfully."

# Cleanup local temp files
rm -f "$ARCHIVE"

# Retention: keep last 7 backups only
if [ -n "$AWS_ENDPOINT_URL" ]; then
  aws --endpoint-url "$AWS_ENDPOINT_URL" s3 ls "s3://$S3_BUCKET/$S3_PATH/" | \
    awk '{print $4}' | grep 'mongo-backup-' | sort | head -n -7 | while read file; do
      echo "[INFO] Deleting old backup: $file"
      aws --endpoint-url "$AWS_ENDPOINT_URL" s3 rm "s3://$S3_BUCKET/$S3_PATH/$file"
    done
else
  aws s3 ls "s3://$S3_BUCKET/$S3_PATH/" | \
    awk '{print $4}' | grep 'mongo-backup-' | sort | head -n -7 | while read file; do
      echo "[INFO] Deleting old backup: $file"
      aws s3 rm "s3://$S3_BUCKET/$S3_PATH/$file"
    done
fi

echo "[INFO] Backup job completed successfully."
