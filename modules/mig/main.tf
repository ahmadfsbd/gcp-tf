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
    # external ip is required on instance for lb health check to pass
    # https://stackoverflow.com/questions/50795561/google-cloud-http-load-balancer-health-check-fails-without-an-external-ip
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


#
# Managed Instance group
#
resource "google_compute_instance_group_manager" "compute_manager_nginx" {
  name               = "compute-manager-nginx"
  project            = var.project
  base_instance_name = "nginx-instance"
  zone               = var.zone

  # application version managed by this manager
  # an existing instance template should be provided
  # a name is optional
  version {
    name              = "nginx-v0.1"
    instance_template = google_compute_instance_template.nginx-web-server.self_link
  }

  # used by load balancer backend services to reference a specific port
  named_port {
    name = "http"
    port = 80
  }
}


#
# Autoscaler
#
resource "google_compute_autoscaler" "nginx_autoscaler" {
  name    = "nginx-autoscaler"
  project = var.project
  zone    = var.zone
  target  = google_compute_instance_group_manager.compute_manager_nginx.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
