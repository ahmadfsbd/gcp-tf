#
# Instance Template
#
resource "google_compute_instance_template" "nginx-web-server" {
  name                 = "nginx-web-server"
  description          = "This template is used to create nginx server instances."
  instance_description = "Instance created by an instance group manager using nginx-web-server template"
  machine_type         = "e2-micro"
  project              = var.project

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image      = "debian-cloud/debian-11"
    auto_delete       = true
    boot              = true
    // backup the disk every day
    #resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    subnetwork = var.subnet_nginx_id
    access_config {
      // Ephemeral public IP
    }
  }

 tags = ["nginx-server"]

  metadata = {
    startup-script = <<EOT
      #!/bin/bash
      # Wait for the apt lock to be released
      # VM auto-updates can cause lock on apt
      while sudo lsof /var/lib/apt/lists/lock /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock; do
        echo "Waiting for apt lock..."
        sleep 10
      done

      # Update package list and install Nginx
      sudo apt-get update
      sudo apt-get install -y nginx

      # Start and enable Nginx
      sudo systemctl start nginx
      sudo systemctl enable nginx
    EOT
  }

#  service_account {
#    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#    email  = google_service_account.default.email
#    scopes = ["cloud-platform"]
#  }
}

#resource "google_compute_resource_policy" "daily_backup" {
#  name   = "every-day-4am"
#  region = "us-central1"
#  snapshot_schedule_policy {
#    schedule {
#      daily_schedule {
#        days_in_cycle = 1
#        start_time    = "04:00"
#      }
#    }
#  }
#}