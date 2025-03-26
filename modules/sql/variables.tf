variable "project" {
    type = string
}

variable "region" {
    type = string
}

variable "zone" {
    type = string
}

variable "vpc_self_link" {
    type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

#eof