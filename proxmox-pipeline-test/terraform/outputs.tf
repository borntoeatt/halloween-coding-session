output "testbox_vmid" {
  value = proxmox_virtual_environment_container.testbox.id
}
output "nextcloud_vmid" {
  value = proxmox_virtual_environment_container.nextcloud.id
}
output "passgen_vmid" {
  value = proxmox_virtual_environment_container.passgen.id
}
