# versions.tf — Terraform version constraints and provider source declarations live here.
# This tells Terraform which version of the CLI is required and where to download
# each provider from. It does NOT configure the provider (that is in provider.tf).
# The required_providers block in each module also declares the source but not the version,
# since versioning is controlled centrally from the root here.

terraform {
  required_version = ">= 1.14.8"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.1"
    }
  }
}
