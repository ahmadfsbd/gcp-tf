module "network" {
	source = "./modules/netowork"

	network_name               = var.network_name
	subnet_cidr                = var.network_cidr
	ssh_allowed_cidr           = var.ssh_allowed_cidr
	ssh_port                   = var.ssh_port
}
