FROM python:3.9-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    cron \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB Database Tools directly from MongoDB
# Detect architecture and download appropriate version
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        wget -q https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-x86_64-100.9.5.tgz -O /tmp/mongodb-tools.tgz; \
    elif [ "$ARCH" = "arm64" ]; then \
        wget -q https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-arm64-100.9.5.tgz -O /tmp/mongodb-tools.tgz; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    tar -xzf /tmp/mongodb-tools.tgz -C /tmp && \
    cp /tmp/mongodb-database-tools-*/bin/* /usr/local/bin/ && \
    rm -rf /tmp/mongodb-tools.tgz /tmp/mongodb-database-tools-*

# Install AWS CLI
RUN pip install --no-cache-dir awscli

# Copy backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]