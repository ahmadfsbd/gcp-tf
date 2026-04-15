resource "openstack_networking_network_v2" "network_1" {
  name           = var.network_name
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  name       = "${var.network_name}-subnet"
  network_id = openstack_networking_network_v2.network_1.id
  cidr       = var.subnet_cidr
  ip_version = 4
}

data "openstack_networking_network_v2" "external_network" {
  count = var.create_router ? 1 : 0
  name  = var.external_network_name
}

resource "openstack_networking_router_v2" "router_1" {
  count               = var.create_router ? 1 : 0
  name                = "${var.network_name}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network[0].id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  count     = var.create_router ? 1 : 0
  router_id = openstack_networking_router_v2.router_1[0].id
  subnet_id = openstack_networking_subnet_v2.subnet_1.id
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "${var.network_name}-sec-group"
  description = "Default security group for this network"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup_1.id
}

