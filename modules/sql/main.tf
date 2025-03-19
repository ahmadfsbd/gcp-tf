

#
# Cloud SQL Instance
#
resource "google_sql_database_instance" "sql_nginx_db" {
  name             = "sql-nginx-db"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project

  #root_password    =

  settings {
    tier        = "db-g1-small"
    disk_type   = "PD_HDD"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.vpc_self_link
      enable_private_path_for_google_cloud_services = true
    }
    location_preference {
        zone = var.zone
    }
  }
}