terraform {
  required_version = ">= 1.3.0, <= 1.13.4"


  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "=0.45.0"
    }
  }
}

