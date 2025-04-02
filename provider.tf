########### Terraform block #########

# Terraform block is used to define terraform specific configs
# i.e. required terraform version, required providers and their version

# Example config below:

#terraform {
#  required_version = "~> 1.6"  # Terraform version must be at least 1.6 but less than 2.0
#
#  required_providers {
#    google = {
#      source  = "hashicorp/google"  # Official Google provider
#      version = "~> 5.5.0"          # Allow any 5.x.x version after 5.5.0
#    }
#    google-beta = {
#      source  = "hashicorp/google-beta"  # Google Beta provider for preview features
#      version = "~> 5.5.0"
#    }
#    kubernetes = {
#      source  = "hashicorp/kubernetes"  # Kubernetes provider
#      version = "~> 2.23.0"
#    }
#  }
#}

terraform {
  required_version = "~> 1.11.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0.0"
    }
  }
}

########### Define your providers here ###############

# Define google terraform provider block
provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  # By default, the project of User/Service account making the api request is
  # tracked against quotas for resources and billed for them. Setting this to 
  # true ensures that resource's project quota is used and in turn that 
  # particular project is billed for the resource in question.
  user_project_override = true
  # API billing project can be defined irrelevant to number of projects. All
  # API calls will be charged to this project. user_project_quota should be
  # set to true for this value to work
  # billing_project = <project>
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/.*"
  ]
}
