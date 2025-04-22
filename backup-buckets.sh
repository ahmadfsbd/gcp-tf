#!/bin/bash

# Authenticate with GCP using the service account key
gcloud auth activate-service-account --key-file="/opt/backup_buckets/adminAccount.json"
if [ $? -ne 0 ]; then
    echo "Error: Failed to authenticate with GCP using the service account key."
    exit 1
fi

# Hardcoded variables
DESTINATION_SUFFIX="-central-backup"
SHORT_DESTINATION_SUFFIX="-central"
BUCKET_NUMBERS=(1 2 3 4 5 6 7 8 9 10 11 13 14 15 16 17) # Add more bucket numbers as needed, e.g., (1 2 3 4)
BUCKETS=(
        qmul-production-sandbox-1-red
        qmul-production-sandbox-2-red
        qmul-production-sandbox-3-red
        qmul-production-sandbox-4-red
        qmul-production-sandbox-5-red
        qmul-production-sandbox-6-red
        qmul-production-sandbox-7-red
        qmul-production-sandbox-8-red
        qmul-production-sandbox-9-red
        qmul-production-sandbox-10-red
        qmul-production-sandbox-11-red
        qmul-production-sandbox-13-red
        qmul-production-sandbox-14-red
        qmul-production-sandbox-15-red
        qmul-production-sandbox-16-red
        qmul-production-sandbox-17-red
        qmul-production-library-red
        qmul-production-library-consortiumpriorityperiod-red
)

# Loop through the buckets and sync
for bucket in "${BUCKETS[@]}"; do
    SOURCE_BUCKET_NAME="${bucket}"

    if [ ${#bucket} -gt 56 ]; then
        DESTINATION_BUCKET_NAME="${bucket}${SHORT_DESTINATION_SUFFIX}"
    else
        DESTINATION_BUCKET_NAME="${bucket}${DESTINATION_SUFFIX}"
    fi

    echo "Syncing from $SOURCE_BUCKET_NAME to $DESTINATION_BUCKET_NAME..."

    # Run the gsutil rsync command
    gsutil -m rsync -r "gs://$SOURCE_BUCKET_NAME/" "gs://$DESTINATION_BUCKET_NAME/"

    if [ $? -eq 0 ]; then
        echo "Sync completed successfully for $SOURCE_BUCKET_NAME"
    else
        echo "Error during sync for $SOURCE_BUCKET_NAME"
        exit 1
    fi
done

echo "Backup completed successfully."
