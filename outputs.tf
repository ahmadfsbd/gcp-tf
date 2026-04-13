output "network_id" {
	description = "Created network ID"
	value       = module.network.network_id
}

output "vm_instance_ids" {
	description = "IDs of created VM instances"
	value       = module.vm.instance_ids
}

output "vm_instance_names" {
	description = "Names of created VM instances"
	value       = module.vm.instance_names
}

output "vm_floating_ips" {
	description = "Floating IPs assigned to VM instances"
	value       = module.vm.floating_ip_addresses
}
