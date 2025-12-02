FROM python:3.9-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    cron \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install MongoDB Database Tools directly from MongoDB
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Architecture detected: $ARCH" && \
    if [ "$ARCH" = "amd64" ]; then \
        TOOLS_URL="https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-x86_64-100.9.5.tgz"; \
    elif [ "$ARCH" = "arm64" ]; then \
        TOOLS_URL="https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-arm64-100.9.5.tgz"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    echo "Downloading from: $TOOLS_URL" && \
    wget --progress=dot:giga "$TOOLS_URL" -O /tmp/mongodb-tools.tgz && \
    echo "Download complete, extracting..." && \
    tar -xzf /tmp/mongodb-tools.tgz -C /tmp && \
    echo "Copying binaries..." && \
    cp /tmp/mongodb-database-tools-*/bin/* /usr/local/bin/ && \
    chmod +x /usr/local/bin/* && \
    echo "Cleaning up..." && \
    rm -rf /tmp/mongodb-tools.tgz /tmp/mongodb-database-tools-* && \
    echo "MongoDB tools installed successfully" && \
    mongodump --version

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