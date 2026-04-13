# provider.tf — Provider configuration lives here.
# This is where you configure HOW Terraform connects to the provider (auth, endpoint, region, etc.).
# The provider source and version are declared separately in versions.tf.
#
# For OpenStack, credentials are read automatically from OS_* environment variables
# set by sourcing your RC file (e.g. source openrc.sh). No hardcoding needed.
# If you need to override any value explicitly, add it inside the provider block.
# Full reference: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
provider "openstack" {}