# MongoDB → S3-Compatible Backup

This container automatically backs up a MongoDB database daily to any S3 or S3-compatible storage (AWS, Backblaze B2, Wasabi, Hetzner, Cloudflare R2, etc).

## Environment Variables

| Variable | Required | Description |
|-----------|-----------|-------------|
| `MONGO_URI` | ✅ | Full MongoDB connection string |
| `AWS_ACCESS_KEY_ID` | ✅ | Access key for S3 provider |
| `AWS_SECRET_ACCESS_KEY` | ✅ | Secret key for S3 provider |
| `AWS_DEFAULT_REGION` | ✅ | Example: `us-east-1` |
| `S3_BUCKET` | ✅ | Target bucket name |
| `S3_PATH` | ✅ | Folder path inside bucket |
| `AWS_ENDPOINT_URL` | ❌ | For non-AWS providers (e.g. `https://s3.us-west-000.backblazeb2.com`) |

## Run Example

```bash
docker run --rm \
  -e MONGO_URI="mongodb://user:pass@mongo:27017/dbname" \
  -e AWS_ACCESS_KEY_ID="KEY" \
  -e AWS_SECRET_ACCESS_KEY="SECRET" \
  -e AWS_DEFAULT_REGION="us-east-1" \
  -e S3_BUCKET="my-bucket" \
  -e S3_PATH="backups" \
  -e AWS_ENDPOINT_U
