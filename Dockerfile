# Use an official lightweight Python image as a base
FROM python:3.10-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-460.0.0-linux-x86_64.tar.gz && \
    tar -xf google-cloud-sdk-460.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \
    rm google-cloud-sdk-460.0.0-linux-x86_64.tar.gz

# Add gcloud to PATH
ENV PATH="/google-cloud-sdk/bin:$PATH"

# Create working directory
WORKDIR /opt/backup_buckets

# Copy your files into the container
COPY adminAccount.json ./adminAccount.json
COPY backup-buckets.sh ./backup-buckets.sh

# Make the script executable
RUN chmod +x ./backup-buckets.sh

# Entry point
ENTRYPOINT ["./backup-buckets.sh"]

