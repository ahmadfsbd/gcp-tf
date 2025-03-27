#
# Enable APIs
#
//  needed for private sql access
resource "google_project_service" "cloud_resource_manager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "gke_api" {
  project = var.project
  service = "container.googleapis.com"

  disable_dependent_services = false
}

#
# Modules
#
module "vpc" {
  source  = "./modules/vpc"
  project = var.project
  region  = var.region
}

module "gke" {
  source  = "./modules/gke"
  project = var.project
  region  = var.region
  network = module.vpc.vpc_web_id
  subnet  = module.vpc.subnet_nginx_id
}

