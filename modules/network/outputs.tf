output "network_id" {
  description = "ID of created network"
  value       = openstack_networking_network_v2.network_1.id
}

output "security_group_name" {
  description = "Name of created default security group"
  value       = openstack_networking_secgroup_v2.secgroup_1.name
}

output "security_group_id" {
  description = "ID of created default security group"
  value       = openstack_networking_secgroup_v2.secgroup_1.id
}

output "router_id" {
  description = "ID of created router, if enabled"
  value       = try(openstack_networking_router_v2.router_1[0].id, null)
}
