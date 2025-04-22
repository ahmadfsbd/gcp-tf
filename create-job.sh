#!/bin/bash

# === CONFIGURATION ===
PROJECT_ID="tre-connection-tester"
REGION="europe-west2"
REPO_NAME="backup-jobs"
IMAGE_NAME="bucket-backup-job"
IMAGE="europe-west2-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME"
JOB_NAME="bucket-backup-service"
SCHEDULER_NAME="bucket-backup-cronjob"
SERVICE_ACCOUNT="cloud-run-scheduler-sa@$PROJECT_ID.iam.gserviceaccount.com"
CRON_SCHEDULE="0 2 * * 0"     # Every Sunday at 2 AM
TIME_ZONE="Europe/London"
DOCKERFILE_PATH="."           # Adjust if your Dockerfile lives elsewhere

# 1) Ensure Artifact Registry repo exists
if ! gcloud artifacts repositories describe "$REPO_NAME" \
     --location="$REGION" \
     --project="$PROJECT_ID" &>/dev/null; then
  echo "📦 Creating Artifact Registry repo: $REPO_NAME"
  gcloud artifacts repositories create "$REPO_NAME" \
    --repository-format=docker \
    --location="$REGION" \
    --description="Docker images for backup jobs" \
    --project="$PROJECT_ID"
else
  echo "✅ Artifact Registry repo '$REPO_NAME' already exists"
fi

# 2) Build & push container
echo "🐳 Building and pushing image $IMAGE"
gcloud builds submit "$DOCKERFILE_PATH" \
  --tag="$IMAGE" \
  --project="$PROJECT_ID"

# 3) Create Scheduler service account if missing
if ! gcloud iam service-accounts describe "$SERVICE_ACCOUNT" \
     --project="$PROJECT_ID" &>/dev/null; then
  echo "🔐 Creating service account $SERVICE_ACCOUNT"
  gcloud iam service-accounts create cloud-run-scheduler-sa \
    --display-name="Cloud Run Scheduler SA" \
    --project="$PROJECT_ID"
else
  echo "✅ Service account '$SERVICE_ACCOUNT' already exists"
fi

# 4) Deploy (or redeploy) Cloud Run job
echo "🚀 Deploying Cloud Run job: $JOB_NAME"
gcloud beta run jobs deploy "$JOB_NAME" \
  --image="$IMAGE" \
  --region="$REGION" \
  --service-account="$SERVICE_ACCOUNT" \
  --max-retries=3 \
  --task-timeout="172800s" \
  --cpu=2 \
  --memory=8Gi \
  --project="$PROJECT_ID"

# 5) Grant run.invoker to Scheduler SA
echo "🔐 Granting roles/run.invoker to $SERVICE_ACCOUNT"
gcloud run jobs add-iam-policy-binding "$JOB_NAME" \
  --region="$REGION" \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/run.invoker" \
  --project="$PROJECT_ID"

# 6) Create or update the Scheduler job
echo "⏱️ Checking for existing scheduler job: $SCHEDULER_NAME"
if gcloud scheduler jobs describe "$SCHEDULER_NAME" \
     --location="$REGION" \
     --project="$PROJECT_ID" &>/dev/null; then

  echo "🔄 Updating scheduler job: $SCHEDULER_NAME"
  gcloud scheduler jobs update http "$SCHEDULER_NAME" \
    --schedule="$CRON_SCHEDULE" \
    --time-zone="$TIME_ZONE" \
    --http-method=POST \
    --uri="https://${REGION}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/$JOB_NAME:run" \
    --message-body="{}" \
    --oauth-service-account-email="$SERVICE_ACCOUNT" \
    --location="$REGION" \
    --project="$PROJECT_ID"

else

  echo "🚀 Creating scheduler job: $SCHEDULER_NAME"
  gcloud scheduler jobs create http "$SCHEDULER_NAME" \
    --schedule="$CRON_SCHEDULE" \
    --time-zone="$TIME_ZONE" \
    --http-method=POST \
    --uri="https://${REGION}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/$PROJECT_ID/jobs/$JOB_NAME:run" \
    --message-body="{}" \
    --oauth-service-account-email="$SERVICE_ACCOUNT" \
    --location="$REGION" \
    --project="$PROJECT_ID"
fi

echo "✅ Done! Cloud Run job '$JOB_NAME' deployed and scheduled as '$SCHEDULER_NAME'."

