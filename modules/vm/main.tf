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

resource "openstack_networking_floatingip_v2" "vm_fip" {
  count = var.assign_floating_ip ? var.vm_count : 0

  pool = var.external_network_name
}

resource "openstack_compute_floatingip_associate_v2" "vm_fip_assoc" {
  count = var.assign_floating_ip ? var.vm_count : 0

  floating_ip = openstack_networking_floatingip_v2.vm_fip[count.index].address
  instance_id = openstack_compute_instance_v2.tf_vm[count.index].id
}