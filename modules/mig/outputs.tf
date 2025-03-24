output "mig_nginx" {
  value = google_compute_instance_group_manager.compute_manager_nginx.instance_group
}