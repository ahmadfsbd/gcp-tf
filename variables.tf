#### Network ####
variable "network_name" {
    description = "Name of the OpenStack network"
    type        = string
}

variable "network_cidr" {
    description = "CIDR of the OpenStack subnet"
    type        = string
}

variable "create_router" {
    description = "Whether to create router and attach subnet"
    type        = bool
    default     = true
}

variable "external_network_name" {
    description = "External network name used for router gateway"
    type        = string
    default     = "public"
}

#### Default Security group ####
variable "ssh_allowed_cidr" {
    description = "CIDR allowed for SSH ingress"
    type        = string
    default     = "0.0.0.0/0"
}

variable "ssh_port" {
    description = "SSH port allowed in security group"
    type        = number
    default     = 22
}

# vms
variable "image_id" {
    description = "uuid of openstack image"
    type        = string
}

variable "flavor_id" {
    description = "ID of openstack flavor"
    type        = string
}

variable "keypair_name" {
    description = "name of openstack keypair"
    type        = string
}

variable "vm_count" {
    description = "number of vms to create"
    type        = number
    default     = 1
}

variable "vm_name_prefix" {
    description = "prefix used for naming VMs"
    type        = string
    default     = "tf-vm"
}

variable "assign_floating_ip" {
    description = "Whether to allocate and associate floating IPs to VMs"
    type        = bool
    default     = true
}
