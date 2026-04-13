#### Network ####
variable "network_name" {
    description = "Name of the OpenStack network"
    type        = string
}

variable "network_cidr" {
    description = "CIDR of the OpenStack subnet"
    type        = string
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

