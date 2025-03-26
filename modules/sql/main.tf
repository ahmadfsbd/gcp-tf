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

# Create a secret in Google Secret Manager
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"
  project   = var.project
  replication {
    auto {}
  }
}

# Add the secret version with the password
resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = var.db_password
}

#
# SQL User
#
resource "google_sql_user" "db_user" {
  name     = "dbuser"
  instance = google_sql_database_instance.sql_nginx_db.name
  password = google_secret_manager_secret_version.db_password_version.secret_data
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