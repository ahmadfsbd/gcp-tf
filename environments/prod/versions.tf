terraform {
  required_version = ">= 1.14.8"

  backend "remote" {
    organization = "ahmadfsbd"

    workspaces {
      name = "gcp-tf-prod"
    }
  }

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.1"
    }
  }
}
