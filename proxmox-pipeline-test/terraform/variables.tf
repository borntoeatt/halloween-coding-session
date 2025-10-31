variable "proxmox_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}
variable "ssh_key" {
  description = "SSH public key for container access"
  type        = string
  sensitive   = true
}
