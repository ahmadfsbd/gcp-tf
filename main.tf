
#
# Modules
#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  region  = var.region
}

module "mig" {
  source  = "./modules/mig"
  project = var.project
  subnet_nginx_id = module.vpc.subnet_nginx_id
}