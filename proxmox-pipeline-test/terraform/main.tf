resource "proxmox_virtual_environment_container" "testbox" {
  node_name = "pve"
  vm_id     = 20001
  clone { vm_id = 9001 }
  description = "Test container"
  cpu { cores = 1 }
  memory { dedicated = 512 }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  features { nesting = true }
  initialization {
    hostname = "testbox"
    ip_config {
      ipv4 { address = "dhcp" }
    }
  }
  start_on_boot = false
  started       = true
}
output "testbox_vmid" {
  value = proxmox_virtual_environment_container.testbox.id
}

