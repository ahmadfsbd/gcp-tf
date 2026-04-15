# Auto-discover available (unattached) floating IPs using the OpenStack CLI
# Runs during terraform plan; requires OS_* env vars to be set
data "external" "available_fips" {
  count = var.assign_floating_ip && var.auto_discover_fips ? 1 : 0
  program = [
    "python3", "-c",
    "import subprocess, json; r = subprocess.run(['openstack', 'floating', 'ip', 'list', '--status', 'DOWN', '-f', 'json'], capture_output=True, text=True); fips = json.loads(r.stdout or '[]'); print(json.dumps({'addresses': ','.join(f['Floating IP Address'] for f in fips)}))"
  ]
}

# Look up each VM's network port so we can associate a floating IP to it
data "openstack_networking_port_v2" "vm_port" {
  count     = var.assign_floating_ip ? var.vm_count : 0
  device_id = openstack_compute_instance_v2.tf_vm[count.index].id
  network_id = var.network_id
}
