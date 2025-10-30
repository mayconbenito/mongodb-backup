# syntax=docker/dockerfile:1
FROM mongo:7.0

RUN apt-get update && apt-get install -y awscli cron gzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY backup.sh /app/backup.sh
COPY crontab.txt /etc/cron.d/mongo-backup

RUN chmod +x /app/backup.sh \
    && chmod 0644 /etc/cron.d/mongo-backup \
    && crontab /etc/cron.d/mongo-backup

CMD ["cron", "-f"]
