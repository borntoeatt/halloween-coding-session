provider "proxmox" {
  endpoint  = "https://192.168.0.100:8006/api2/json"
  api_token = var.proxmox_token
  insecure  = true
}

###############################################
# TESTBOX (conditionally created)
###############################################
resource "proxmox_virtual_environment_container" "testbox" {
  count = var.deploy_testbox ? 1 : 0

  node_name = "pve"
  vm_id     = 20001

  clone {
    vm_id = 9001
  }

  description = "Test container"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "testbox"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  start_on_boot = false
  started       = true
}

###############################################
# NEXTCLOUD (conditionally created)
###############################################
resource "proxmox_virtual_environment_container" "nextcloud" {
  count = var.deploy_nextcloud ? 1 : 0

  node_name = "pve"
  vm_id     = 20009

  clone {
    vm_id = 9001
  }

  description = "Nextcloud container"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "nextcloud"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  start_on_boot = false
  started       = true
}

###############################################
# PASSGEN (conditionally created)
###############################################
resource "proxmox_virtual_environment_container" "passgen" {
  count = var.deploy_passgen ? 1 : 0

  node_name = "pve"
  vm_id     = 20010

  clone {
    vm_id = 9001
  }

  description = "passgen"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "passgen"
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  start_on_boot = false
  started       = true
}
