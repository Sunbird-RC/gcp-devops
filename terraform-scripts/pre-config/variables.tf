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
    region  = string
  })
  default = {
    region  = ""
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
    proxy_subnet = object({
      name          = string
      ip_cidr_range = string
    })
    psc_subnet = object({
      name          = string
      ip_cidr_range = string
    })
    operations_subnet = object({
      name          = string
      ip_cidr_range = string
    })
    db_subnet = object({
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
    psc_subnet = {
      name          = ""
      ip_cidr_range = ""
      purpose       = ""
    }
    proxy_subnet = {
      name          = ""
      ip_cidr_range = ""
      purpose       = ""
    }
    operations_subnet = {
      name          = "",
      ip_cidr_range = ""
    }
    db_subnet = {
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

variable "artifactRegistryInfo" {
  type = object({
    name        = string
    description = string
    format      = string
  })

  default = {
    name        = ""
    description = ""
    format      = "DOCKER"
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

variable "memstoreInfo" {
  type = object({
    name         = string
    display_name = string
    tier         = string
    sizeInGB     = number
  })
  default = {
    name         = ""
    display_name = ""
    tier         = "BASIC"
    sizeInGB     = 1
  }
}

variable "fuseStorageInfo" {
  type = object({
    name                        = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
    public_access_prevention    = string
  })
  default = {
    name                        = ""
    uniform_bucket_level_access = true
    force_destroy               = true
    public_access_prevention    = "enforced"
  }
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