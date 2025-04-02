#
# Service Account
#
resource "google_service_account" "sa_node_pool_web" {
  account_id   = "sa-node-pool-web"
  display_name = "GKE Web Node Pool SA"
  project      = var.project
}

// add this role for node logging to work properly
resource "google_project_iam_member" "sa_node_pool_web_permissions" {
  project = var.project
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.sa_node_pool_web.email}"
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
  node_count = 2 #2 per zone in this case, autoscalling will take precedence and this fixed number of nodes will be ignored

  node_config {
    preemptible       = false
    machine_type      = "e2-small"
    disk_size_gb      = 11
    disk_type         = "pd-standard"
    image_type        = "COS_CONTAINERD"
    labels            = {}
    local_ssd_count   = 0
    logging_variant   = "DEFAULT"
    spot            = false
    tags            = []
    
    metadata = {
      "disable-legacy-endpoints" = "true"
    }
    
    resource_labels = {
      "goog-gke-node-pool-provisioning-model" = "on-demand"                                                                          
    }

    kubelet_config {
      cpu_manager_policy = "none"
      cpu_cfs_quota      = false
      pod_pids_limit     = 0
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = false
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.sa_node_pool_web.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # cluster will have anywhere from 3 nodes (1 per zone) to 9 (3 per zone)
  autoscaling {
    location_policy      = "BALANCED" # balanced across the AZs
    max_node_count       = 3 #3 per zone
    min_node_count       = 1 #1 per zone
    total_max_node_count = 0 #no total limit as per zone limits are applied
    total_min_node_count = 0 #no total limit as per zone limits are applied
  }

  upgrade_settings {
    max_surge       = 1 #add 1 extra nodes (max) at a time to upgrade cluster
    max_unavailable = 0 #zero downtime, don't remove a node untill a replacement is available
    strategy        = "SURGE"
  }

  lifecycle {
    ignore_changes = [
      node_count,                            # Allow node count to be controlled outside terraform
      network_config[0].enable_private_nodes # Can be false for old clusters, they use endpoint and forwarding rule to connect to control plane
    ]
  }

}