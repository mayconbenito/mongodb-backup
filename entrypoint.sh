#!/bin/bash
set -e

# Set default cron schedule to daily at midnight if not provided
CRON_SCHEDULE="${CRON_SCHEDULE:-0 0 * * *}"

echo "Starting MongoDB backup container"
echo "Cron schedule: ${CRON_SCHEDULE}"

# Validate required environment variables
if [ -z "$MONGO_URI" ]; then
    echo "Error: MONGO_URI environment variable is required"
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Error: AWS_ACCESS_KEY_ID environment variable is required"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: AWS_SECRET_ACCESS_KEY environment variable is required"
    exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
    echo "Error: AWS_DEFAULT_REGION environment variable is required"
    exit 1
fi

if [ -z "$S3_BUCKET" ]; then
    echo "Error: S3_BUCKET environment variable is required"
    exit 1
fi

if [ -z "$S3_PATH" ]; then
    echo "Error: S3_PATH environment variable is required"
    exit 1
fi

# Export environment variables for cron
printenv | grep -E '^(MONGO_URI|AWS_|S3_)' > /etc/environment

# Create cron job with the schedule from environment variable
echo "${CRON_SCHEDULE} /usr/local/bin/backup.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/mongodb-backup

# Give execution rights on the cron job
chmod 0644 /etc/cron.d/mongodb-backup

# Apply cron job
crontab /etc/cron.d/mongodb-backup

# Create the log file
touch /var/log/cron.log

echo "Cron job created successfully"
echo "Running initial backup..."

# Run initial backup
/usr/local/bin/backup.sh

echo "Initial backup completed"
echo "Starting cron daemon..."

# Start cron in foreground
cron && tail -f /var/log/cron.log