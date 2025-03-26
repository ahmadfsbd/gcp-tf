variable "project" {
    type = string
    default = "teraform101"
}

variable "region" {
    type = string
    default = "europe-west2"
}

variable "zone" {
    type = string
    default = "europe-west2-a"
}

# Prompt for the password
variable "db_password" {
  type      = string
  sensitive = true
  description = "The password for the Cloud SQL database"
}

#eof