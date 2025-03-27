#
# Service Account
#
resource "google_service_account" "sa_node_pool_web" {
  account_id   = "sa-node-pool-web"
  display_name = "GKE Web Node Pool SA"
  project      = var.project
}


#
# GKE Cluster
#
resource "google_container_cluster" "primary" {
  name          = "primary-gke-cluster"
  location      = var.region
  network       = var.network
  subnetwork    = var.subnet

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

#
# GKE Node Pool
#
resource "google_container_node_pool" "web_server_nodes" {
  name       = "web-server-nodes"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  #node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.sa_node_pool_web.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    total_min_node_count    = 1
    total_max_node_count    = 3
    location_policy         = "BALANCED"
  }
}