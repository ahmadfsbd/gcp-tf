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

  deletion_protection = false

}

#
# SQL User
#
resource "google_sql_user" "db_user" {
  name     = "dbuser"
  instance = google_sql_database_instance.sql_nginx_db.name
  password = "password"
  project  = var.project
}
# Could use a gcp secret in place of specifying password directly

#
# CloudSQL DB
#
resource "google_sql_database" "nginx_db" {
  name     = "nginx-db"  # Name of the database
  instance = google_sql_database_instance.sql_nginx_db.name
  project  = var.project
}

### Verify Access ###
# From the nginx-vm run: $ psql -h <sql-private-ip> -U dbuser -d nginx-db 