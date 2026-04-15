# Look up each VM's network port so we can associate a floating IP to it
data "openstack_networking_port_v2" "vm_port" {
  count     = var.assign_floating_ip ? var.vm_count : 0
  device_id = openstack_compute_instance_v2.tf_vm[count.index].id
  network_id = var.network_id
}
