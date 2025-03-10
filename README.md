# Creating The GCP Stack Using Terraform

## Initial Setup

Follow these steps to configure the GCP and Terraform:

1. Run 'make gcloud-init' and autheticate using gcp admin email. Enter configuration name, default project to be used and default region/zone, when asked. Name the config 'gcp-tf' for consistency, change Makefile 'auth'section too if you need to change config name.

   Note: If creating a new project as part of init, project ID must be globally unique accross all of GCP.

   Note: If you want to set the default zone as part of init command, the compute engine api should be enabled prior. You can also manually set the default region/zone for the config:
   * gcloud config set compute/region <REGION>
   * gcloud config set compute/zone <ZONE>
   * A list of regions and zones can be found at: https://cloud.google.com/compute/docs/regions-zones

2. Activate the correct gcp config for this repo using 'make auth'.
3. Configure application-default-login credentials by running 'make adc-login'
4. Create a tfstate bucket to store terraform states 'make create-tfstate-bucket'
5. Initialize terraform and gcs backend by running 'make init'
