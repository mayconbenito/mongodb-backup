FROM mongo:7.0

# Install AWS CLI, cron, and gzip
RUN apt-get update && apt-get install -y \
    awscli \
    cron \
    gzip \
    && rm -rf /var/lib/apt/lists/*

# Copy backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]