terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "=0.45.0"
    }
  }
}

