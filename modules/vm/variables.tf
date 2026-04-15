variable "image_id" {
    description = "UUID of OpenStack image"
    type        = string
}

variable "flavor_id" {
    description = "ID of OpenStack flavor"
    type        = string
}

variable "keypair_name" {
    description = "Name of OpenStack keypair"
    type        = string
}

variable "vm_count" {
    description = "Number of VMs to create"
    type        = number
    default     = 1
}

variable "vm_name_prefix" {
    description = "Prefix used for VM names"
    type        = string
    default     = "tf-vm"
}

variable "network_id" {
    description = "OpenStack network UUID where VMs are attached"
    type        = string
}

variable "security_group_name" {
    description = "Security group name assigned to VMs"
    type        = string
}

variable "assign_floating_ip" {
    description = "Whether to allocate and associate floating IPs to VMs"
    type        = bool
    default     = true
}

variable "external_network_name" {
    description = "External network name used to allocate floating IPs"
    type        = string
    default     = "public"
}

variable "existing_floating_ips" {
    description = "List of existing floating IP addresses to reuse (consumed first before allocating new ones)"
    type        = list(string)
    default     = []
}


