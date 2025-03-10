# authenticate with gcp and configure defaults
gcloud-init:
	gcloud init --console-only

# activate existing gcp configuration
auth: 
	gcloud config configurations activate gcp-tf

# authenticate Application Default Credentials (ADC) for applications
# running on local machine that need to access GCP services through API calls.
adc-login:
	gcloud auth application-default login --disable-quota-project --no-launch-browser

# set ADC quota project
adc-project:

