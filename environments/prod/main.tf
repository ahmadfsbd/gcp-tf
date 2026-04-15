locals {
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "tf-${var.tf_env}"
}

module "network" {
  source = "../../modules/network"

  network_name          = "${local.resource_prefix}-network"
  subnet_cidr           = var.network_cidr
  create_router         = var.create_router
  external_network_name = var.external_network_name
  ssh_allowed_cidr      = var.ssh_allowed_cidr
  ssh_port              = var.ssh_port
}

module "vm" {
  source = "../../modules/vm"

  depends_on = [module.network]

  vm_count              = var.vm_count
  vm_name_prefix        = local.resource_prefix
  image_id              = var.image_id
  flavor_id             = var.flavor_id
  keypair_name          = var.keypair_name
  network_id            = module.network.network_id
  security_group_name   = module.network.security_group_name
  assign_floating_ip    = var.assign_floating_ip
  external_network_name = var.external_network_name
  existing_floating_ips = var.existing_floating_ips
}
