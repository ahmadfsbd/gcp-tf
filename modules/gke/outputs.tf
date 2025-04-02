# Output the necessary cluster information
output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "google_container_cluster_primary" {
  value = google_container_cluster.primary
}