# Terraform Cloud backend configuration.
# Workspaces are selected via `terraform workspace select/new`.

terraform {
  backend "remote" {
    organization = "ahmadfsbd"

    workspaces {
      prefix = "gcp-tf-"
    }
  }
}
