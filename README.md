# MongoDB Backup with Configurable Cron Schedule

This container automatically backs up a MongoDB database to any S3 or S3-compatible storage (AWS, Backblaze B2, Wasabi, Hetzner, Cloudflare R2, etc) with a **configurable cron schedule**.

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MONGO_URI` | ✅ | - | Full MongoDB connection string |
| `AWS_ACCESS_KEY_ID` | ✅ | - | Access key for S3 provider |
| `AWS_SECRET_ACCESS_KEY` | ✅ | - | Secret key for S3 provider |
| `AWS_DEFAULT_REGION` | ✅ | - | Example: `us-east-1` |
| `S3_BUCKET` | ✅ | - | Target bucket name |
| `S3_PATH` | ✅ | - | Folder path inside bucket |
| `AWS_ENDPOINT_URL` | ❌ | - |  |
| `CRON_SCHEDULE` | ❌ | `0 0 * * *` | Cron schedule expression (defaults to daily at midnight) |

## Cron Schedule Examples

The `CRON_SCHEDULE` variable accepts standard cron expressions:

| Schedule | Expression | Description |
|----------|-----------|-------------|
| Every hour | `0 * * * *` | Run at the start of every hour |
| Every 6 hours | `0 */6 * * *` | Run every 6 hours |
| Daily at 2 AM | `0 2 * * *` | Run at 2:00 AM every day |
| Daily at midnight | `0 0 * * *` | Run at 12:00 AM every day (default) |
| Twice daily | `0 0,12 * * *` | Run at midnight and noon |
| Weekly | `0 0 * * 0` | Run at midnight every Sunday |
| Every 30 minutes | `*/30 * * * *` | Run every 30 minutes |

### Cron Expression Format

```
* * * * *
│ │ │ │ │
│ │ │ │ └─ Day of week (0-7, 0 and 7 are Sunday)
│ │ │ └─── Month (1-12)
│ │ └───── Day of month (1-31)
│ └─────── Hour (0-23)
└───────── Minute (0-59)
```

## Usage Examples

### Daily Backup (Default)

```bash
docker run -d \
  -e MONGO_URI="mongodb://user:pass@mongo:27017/dbname" \
  -e AWS_ACCESS_KEY_ID="KEY" \
  -e AWS_SECRET_ACCESS_KEY="SECRET" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e S3_BUCKET="my-bucket" \
  -e S3_PATH="backups" \
  mongodb-backup
```

### Hourly Backup

```bash
docker run -d \
  -e MONGO_URI="mongodb://user:pass@mongo:27017/dbname" \
  -e AWS_ACCESS_KEY_ID="KEY" \
  -e AWS_SECRET_ACCESS_KEY="SECRET" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e S3_BUCKET="my-bucket" \
  -e S3_PATH="backups" \
  -e CRON_SCHEDULE="0 * * * *" \
  mongodb-backup
```

### Every 6 Hours

```bash
docker run -d \
  -e MONGO_URI="mongodb://user:pass@mongo:27017/dbname" \
  -e AWS_ACCESS_KEY_ID="KEY" \
  -e AWS_SECRET_ACCESS_KEY="SECRET" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e S3_BUCKET="my-bucket" \
  -e S3_PATH="backups" \
  -e CRON_SCHEDULE="0 */6 * * *" \
  mongodb-backup
```

### With Non-AWS S3 Provider (Backblaze B2)

```bash
docker run -d \
  -e MONGO_URI="mongodb://user:pass@mongo:27017/dbname" \
  -e AWS_ACCESS_KEY_ID="KEY" \
  -e AWS_SECRET_ACCESS_KEY="SECRET" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e S3_BUCKET="my-bucket" \
  -e S3_PATH="backups" \
  -e AWS_ENDPOINT_URL="https://s3.us-west-000.backblazeb2.com" \
  -e CRON_SCHEDULE="0 2 * * *" \
  mongodb-backup
```

## Docker Compose Example

```yaml
version: '3.8'

services:
  mongodb-backup:
    image: mongodb-backup:latest
    environment:
      - MONGO_URI=mongodb://user:pass@mongo:27017/dbname
      - AWS_ACCESS_KEY_ID=your-key
      - AWS_SECRET_ACCESS_KEY=your-secret
      - AWS_DEFAULT_REGION=us-east-1
      - S3_BUCKET=my-bucket
      - S3_PATH=backups
      - CRON_SCHEDULE=0 */6 * * *  # Every 6 hours
    restart: unless-stopped
```

## Building the Image

```bash
docker build -t mongodb-backup:latest .
```

## Features

- ✅ Configurable backup schedule via `CRON_SCHEDULE` environment variable
- ✅ Automatic initial backup on container start
- ✅ Support for AWS S3 and S3-compatible providers
- ✅ Timestamped backup files
- ✅ Compressed backups (tar.gz)
- ✅ Logs visible via `docker logs`
- ✅ Automatic cleanup of temporary files

## Logs

View backup logs:

```bash
docker logs -f <container-name>
```

## Backup File Format

Backups are stored with the format: `mongodb_backup_YYYYMMDD_HHMMSS.tar.gz`

Example: `mongodb_backup_20241202_140530.tar.gz`