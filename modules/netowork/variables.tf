variable "network_name" {
	description = "Name of the OpenStack network to create"
	type        = string
}

variable "subnet_cidr" {
	description = "CIDR block for the subnet in the network"
	type        = string
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