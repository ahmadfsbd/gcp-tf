variable "network_name" {
	description = "Name of the OpenStack network to create"
	type        = string
}

variable "subnet_cidr" {
	description = "CIDR block for the subnet in the network"
	type        = string
}

variable "create_router" {
	description = "Whether to create a router and attach subnet for external connectivity"
	type        = bool
	default     = true
}

variable "external_network_name" {
	description = "Name of the external network used as router gateway"
	type        = string
	default     = "public"
}

variable "ssh_allowed_cidr" {
	description = "CIDR allowed to access SSH"
	type        = string
	default     = "0.0.0.0/0"
}

variable "ssh_port" {
	description = "SSH port to allow in security group"
	type        = number
	default     = 22
}