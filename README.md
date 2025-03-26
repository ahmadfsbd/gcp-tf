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
6. Enable APIs 'make enable-apis'

## Deploy Terraform Changes to GCP
1. Run terraform plan to see the changes are as desired 'make plan'
2. Run terraform apply to apply the changes 'make apply'

## Development
1. Add the desired functionality, add features as modules preferably
2. Run 'make init' to initialize terraform again and import the modules
3. Run terraform plan and apply

## Tips
1. Resources that are up in heirarchy, can further be converted into modules. For example, in a multi-project scenario, a project (and all if its resources within) could be a single module.
2. Multiple resources or projects could be created using modules and having dynamic template generation through resource count/variables in variables.tf. Dynamic generation is natively supported in Terraform.
3. Its best to create a separate tf work directory to create security policies and VPC perimiter configs, or it could be another module.
4. Terraform supports creating nested modules.