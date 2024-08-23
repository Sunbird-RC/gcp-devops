variable "project_id" {
  type = string
}
variable "sql_ip_name" {
  type = string
}
variable "service_account" {
  type = string
}
variable "projectInfo" {
  type = object({
    region = string
    name   = string
  })
  default = {
    region = ""
    name   = ""
  }
}

variable "services" {
  type = list(string)

  default = [""]
}

variable "networkInfo" {
  type = object({
    name                    = string
    auto_create_subnetworks = bool
    mtu                     = number
    gke_subnet = object({
      name          = string
      ip_cidr_range = string
      pods_ip_range = object({
        range_name    = string
        ip_cidr_range = string
      })
      services_ip_range = object({
        range_name    = string
        ip_cidr_range = string
      })
    })
    operations_subnet = object({
      name          = string
      ip_cidr_range = string
    })
  })

  default = {
    name                    = ""
    auto_create_subnetworks = false
    mtu                     = 1460
    gke_subnet = {
      name          = ""
      ip_cidr_range = ""
      pods_ip_range = {
        range_name    = ""
        ip_cidr_range = ""
      }
      services_ip_range = {
        range_name    = ""
        ip_cidr_range = ""
      }
    }
    operations_subnet = {
      name          = "",
      ip_cidr_range = ""
    }
  }
}

variable "firewallPolicyInfo" {
  type = object({
    name        = string
    description = string
  })

  default = {
    name        = ""
    description = ""
  }
}

variable "firewallPolicyAssocInfo" {
  type = object({
    name = string
  })

  default = {
    name = ""
  }
}

variable "firewallRuleInfo" {
  type = list(object({
    name            = string
    action          = string
    description     = string
    direction       = string
    disabled        = bool
    enable_logging  = bool
    firewall_policy = string
    priority        = number
    match = object({
      src_ip_ranges  = optional(list(string))
      dest_ip_ranges = optional(list(string))
      layer4_configs = object({
        ip_protocol = string
        ports       = optional(list(string))
      })
    })
  }))

  default = [
    {
      name            = ""
      action          = "allow"
      description     = ""
      direction       = "INGRESS"
      disabled        = false
      enable_logging  = false
      firewall_policy = ""
      priority        = 100
      match = {
        src_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = {
          ip_protocol = "tcp"
          ports       = ["22"]
        }
      }
    },
    {
      name            = ""
      action          = "allow"
      description     = ""
      direction       = "INGRESS"
      disabled        = false
      enable_logging  = true
      firewall_policy = ""
      priority        = 101
      match = {
        src_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = {
          ip_protocol = "tcp"
          ports       = ["80", "443", "8080"]
        }
      }
    },
    {
      name            = ""
      action          = "allow"
      description     = ""
      direction       = "INGRESS"
      disabled        = false
      enable_logging  = true
      firewall_policy = ""
      priority        = 102
      match = {
        src_ip_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
        layer4_configs = {
          ip_protocol = "tcp"
        }
      }
    },
    {
      name            = ""
      action          = "allow"
      description     = ""
      direction       = "INGRESS"
      disabled        = false
      enable_logging  = false
      firewall_policy = ""
      priority        = 103
      match = {
        src_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = {
          ip_protocol = "tcp"
          ports       = ["5432"]
        }
      }
    },
    {
      name            = ""
      action          = "allow"
      description     = ""
      direction       = "EGRESS"
      disabled        = false
      enable_logging  = false
      firewall_policy = ""
      priority        = 104
      match = {
        dest_ip_ranges = ["0.0.0.0/0"]
        layer4_configs = {
          ip_protocol = "tcp"
        }
      }
  }]
}

variable "lbipInfo" {
  type = object({
    name = string
  })

  default = {
    name = ""
  }
}

variable "natipInfo" {
  type = object({
    name = string
  })

  default = {
    name = "sunbirdrc-dev-nat-gw-ip"
  }
}

variable "routerInfo" {
  type = object({
    name = string
    routerNAT = object({
      name = string
    })
  })

  default = {
    name = ""
    routerNAT = {
      name = ""
    }
  }
}

variable "sqlInfo" {
  type = object({
    instanceName = string
    version      = string
    settings = object({
      tier         = string
      ipv4_enabled = bool
    })
    protection = bool
  })
  default = {
    instanceName = ""
    version      = "POSTGRES_14"
    settings = {
      tier         = ""
      ipv4_enabled = true
    }
    protection = false
  }
}

variable "dbInfo" {
  type = list(object({
    name         = string
    instanceName = string
  }))

  default = [{
    name         = "",
    instanceName = ""
  }]
}


variable "opsVMInfo" {
  type = object({
    name         = string
    ip_name      = string
    machine_type = string
    zone         = string
    tags         = optional(list(string))
    boot_disk = object({
      image = string
    })
  })
  default = {
    name         = ""
    ip_name      = ""
    machine_type = ""
    zone         = ""
    boot_disk = {
      image = "s"
    }
  }
}

variable "secretInfo" {
  type = object({
    name = string
  })

  default = {
    name = ""
  }
}

variable "clusterInfo" {
  type = object({
    name                = string
    initial_node        = number
    deletion_protection = bool
    networking_mode     = string
    release_channel     = string
    remove_default_pool = bool
    network_policy      = bool
    pod_autoscale       = bool
    gcsfuse_csi         = bool
    private_cluster_config = object({
      enable_private_nodes        = bool
      enable_private_endpoint     = bool
      master_ipv4_cidr_block      = string
      master_global_access_config = bool
    })
    master_authorized_networks_config = object({
      gcp_public_cidrs_access_enabled = bool
    })
    nodepool_config = list(object({
      name              = string
      machine_type      = string
      initial_node      = number
      min_node          = number
      max_node          = number
      max_pods_per_node = number
    }))
  })

  default = {
    name                = "-cluster"
    initial_node        = 1
    deletion_protection = false
    networking_mode     = "VPC_NATIVE"
    release_channel     = "STABLE"
    remove_default_pool = true
    network_policy      = true
    pod_autoscale       = true
    gcsfuse_csi         = true
    private_cluster_config = {
      enable_private_nodes        = false
      enable_private_endpoint     = false
      master_ipv4_cidr_block      = ""
      master_global_access_config = false
    }
    master_authorized_networks_config = {
      gcp_public_cidrs_access_enabled = false
      cidr_blocks = {
        cidr_block = ""
      }
    }
    nodepool_config = [
      {
        name              = "system-pool"
        machine_type      = "e2-medium"
        initial_node      = 1
        max_node          = 2
        max_pods_per_node = 30
        min_node          = 1
      },
      {
        name              = "worker-pool"
        machine_type      = "n2d-standard-2"
        initial_node      = 1
        max_node          = 5
        max_pods_per_node = 50
        min_node          = 1
    }]
  }
}

variable "vpnInfo" {
  type = object({
    gateway_1_asn    = number
    gateway_2_asn    = number
    bgp_range_1      = string
    bgp_range_2      = string
    workerpool_range = string

  })
  default = {
    gateway_1_asn    = 65007
    gateway_2_asn    = 65008
    bgp_range_1      = "169.254.7.0/30"
    bgp_range_2      = "169.254.8.0/30"
    workerpool_range = "10.37.0.0"
  }
}