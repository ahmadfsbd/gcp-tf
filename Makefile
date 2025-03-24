GIT_BRANCH := $(shell git branch --show-current)
# Default compute region in active gcloud config, cloud be changed
REGION := $(shell gcloud config list --format='value(compute.region)')
# Default project in active gcloud config, cloud be changed
PROJECT := $(shell gcloud config list --format='value(core.project)')
TF_STATE_BUCKET := $(PROJECT)-tfstate

all: none

# Authenticate with gcp and configure defaults
gcloud-init:
	gcloud init --console-only

# Activate existing gcp configuration
auth: 
	gcloud config configurations activate gcp-tf

# Authenticate Application Default Credentials (ADC) for applications
# running on local machine that need to access GCP services through API calls.
adc-login:
	gcloud auth application-default login --disable-quota-project --no-launch-browser

# Set ADC quota project
adc-project:

# Create a bucket to store terraform states and enable versioning
create-tfstate-bucket:
	gcloud storage buckets create gs://$(TF_STATE_BUCKET) --location $(REGION) \
	--project $(PROJECT) --public-access-prevention
	gcloud storage buckets update gs://$(TF_STATE_BUCKET) --project $(PROJECT) \
	--versioning

enable-apis: auth
	gcloud --project=$(PROJECT) \
		services enable cloudresourcemanager.googleapis.com
	gcloud --project=$(PROJECT) \
		services enable servicenetworking.googleapis.com

# Initialize terraform backend (gcs) and create state file in gcp bucket
# The local .terraform directory will be used by terraform to store data
# such as statefile, plugins for providers, and configuration files
init:
	TF_DATA_DIR=".terraform-$(GIT_BRANCH)" terraform init -reconfigure \
		-backend-config="bucket=$(TF_STATE_BUCKET)" --upgrade

plan:
	TF_DATA_DIR=".terraform-$(GIT_BRANCH)" terraform plan | tee plan.log

apply:
	TF_DATA_DIR=".terraform-$(GIT_BRANCH)" terraform apply

destroy:
	TF_DATA_DIR=".terraform-$(GIT_BRANCH)" terraform destroy
