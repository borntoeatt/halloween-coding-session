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
variable "deploy_testbox" {
  type    = bool
  default = true
}

variable "deploy_nextcloud" {
  type    = bool
  default = true
}

variable "deploy_passgen" {
  type    = bool
  default = true
}

variable "proxmox_token" {
  type = string
}
