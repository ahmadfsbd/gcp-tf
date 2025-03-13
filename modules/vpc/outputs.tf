output "vpc_web_id" {
  description = "The ID of the web VPC network"
  value       = google_compute_network.vpc_network_web.id
}

output "subnet_nginx_id" {
  description = "The ID of the nginx subnet"
  value       = google_compute_subnetwork.vpc_network_web_subnet_nginx.id
}

output "subnet_db_id" {
  description = "The ID of the db subnet"
  value       = google_compute_subnetwork.vpc_network_web_subnet_db.id
}

output "vpc_web_self_link" {
  value = google_compute_network.vpc_network_web.self_link
}