resource "openstack_compute_instance_v2" "tf_vm" {
  count           = var.vm_count
  name            = format("%s-%02d", var.vm_name_prefix, count.index + 1)
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = var.keypair_name
  security_groups = [var.security_group_name]

  network {
    uuid = var.network_id
  }
}

# Only allocate new FIPs for VMs not covered by explicitly reused ones
resource "openstack_networking_floatingip_v2" "vm_fip" {
  count = var.assign_floating_ip ? max(0, var.vm_count - length(var.existing_floating_ips)) : 0
  pool  = var.external_network_name
}

locals {
  all_fip_addresses = concat(
    var.existing_floating_ips,
    [for fip in openstack_networking_floatingip_v2.vm_fip : fip.address],
  )
}

resource "openstack_networking_floatingip_associate_v2" "vm_fip_assoc" {
  count = var.assign_floating_ip ? var.vm_count : 0

  floating_ip = local.all_fip_addresses[count.index]
  port_id     = data.openstack_networking_port_v2.vm_port[count.index].id
}