output "instance_ids" {
  description = "IDs of created VM instances"
  value       = openstack_compute_instance_v2.tf_vm[*].id
}

output "instance_names" {
  description = "Names of created VM instances"
  value       = openstack_compute_instance_v2.tf_vm[*].name
}

output "floating_ip_addresses" {
  description = "Floating IP addresses associated to VMs"
  value       = [for f in openstack_networking_floatingip_v2.vm_fip : f.address]
}
