# Guide
This deploys a cloud-run job in GCP that is triggered by cloud scheduler. The cloud-run job runs a container that runs rsync between buckets weekly.

## Pre-reqs
1. Enable Required APIs in Gcloud including cloud-run, cloud-scheduler, artifact registry etc.
2. Create a file 'adminAccount.json' in current dir that has the json key of the SA that can perform the sync operations. Look into IAM > ServiceAccoun
ts >> Select Service Account >> Keys
3. Modify the 'create-job.sh' script to make sure the project name, zone and other variables are as expected.

## Create resources
1. Simply run the script $./create-job.sh

## Modify the list of buckets
1. This can be done from the backup-buckets.sh
