#
# VPC networks
#
resource "google_compute_network" "vpc_network_web" {
  project                 = var.project
  name                    = "${var.project}-network-web"
  auto_create_subnetworks = false
}

#
# VPC subnets
#
resource "google_compute_subnetwork" "vpc_network_web_subnet_nginx" {
  name          = "nginx-subnet"
  description   = "A subnet that will host Nginx website VMs"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network_web.id
  # access google apis without public ip
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "vpc_network_web_subnet_db" {
  name          = "db-subnet"
  description   = "A subnet that will host DB for Nginx"
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network_web.id
  # access google apis without public ip
  private_ip_google_access = true
}

#
# Firewall Rules
#
resource "google_compute_firewall" "net-web-allow-ssh-and-https" {
  name    = "allow-ssh-and-https"
  network = google_compute_network.vpc_network_web.name

  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
}