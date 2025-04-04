#
# Enable APIs
#
//  needed for private sql access
resource "google_project_service" "cloud_resource_manager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

#
# Modules
#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  region  = var.region
}

module "mig" {
  source          = "./modules/mig"
  project         = var.project
  subnet_nginx_id = module.vpc.subnet_nginx_id
  zone            = var.zone
}

module "sql" {
  source              = "./modules/sql"
  project             = var.project
  region              = var.region
  zone                = var.zone
  vpc_self_link       = module.vpc.vpc_web_self_link
  db_password         = var.db_password
  depends_on          = [module.vpc.cloud_sql_private_connection]
}

module "lb" {
  source          = "./modules/lb"
  project         = var.project
  mig_nginx       = module.mig.mig_nginx
}

