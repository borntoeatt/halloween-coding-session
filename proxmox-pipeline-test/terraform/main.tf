provider "proxmox" {
  endpoint  = "https://192.168.0.100:8006/api2/json"
  api_token = var.proxmox_token
  insecure  = true
}

resource "proxmox_virtual_environment_container" "testbox" {
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

# Nextcloud container
resource "proxmox_virtual_environment_container" "nextcloud" {
  #depends_on = [proxmox_virtual_environment_container.testbox]
  node_name  = "pve"
  vm_id      = 20009
  clone {
    vm_id = 9001
  }
  description = "Test nextcloud container"
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

# Passgen container
resource "proxmox_virtual_environment_container" "passgen" {
  #depends_on = [proxmox_virtual_environment_container.testbox]
  node_name  = "pve"
  vm_id      = 20010
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
