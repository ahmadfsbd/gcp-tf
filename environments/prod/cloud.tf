# Terraform Cloud workspace configuration for the prod environment.
# This file is copied to the project root by scripts/use-env.sh.
# Do not edit the root cloud.tf directly — edit this source file instead.

terraform {
  cloud {
    organization = "ahmadfsbd"

    workspaces {
      name = "gcp-tf-prod"
    }
  }
}
