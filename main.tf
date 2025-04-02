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

module "gke" {
  source  = "./modules/gke"
  project = var.project
  region  = var.region
  network = module.vpc.vpc_web_id
  subnet  = module.vpc.subnet_nginx_id
}

# Adding a time delay after the GKE cluster deployment (optional)
resource "time_sleep" "wait_after_gke_deployment" {
  depends_on = [module.gke]  # Waits for the GKE cluster creation

  destroy_duration = "180s"  # Wait for 3 minutes after GKE cluster creation
}

#
# K8S Application Deployment
#
module "k8s" {
  source  = "./modules/k8s"
  depends_on = [module.gke]  # Ensures that k8s deployment happens after GKE cluster is created
}