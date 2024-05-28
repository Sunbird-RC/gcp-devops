projectInfo = {
        project = "<PROJECT_ID>"
        region = "asia-south1"
}

serviceAccountInfo = {
    name = "<PROJECT_ID>-sa@<PROJECT_ID>.iam.gserviceaccount.com"
}

networkInfo = {
    name = "<NAME>-dev-vpc"
    auto_create_subnetworks = false
    mtu = 1460
    gke_subnet = {
        name = "<NAME>-dev-gke-subnet"
        ip_cidr_range = "10.0.0.0/24"
        pods_ip_range = {
            range_name = "pods-range"
            ip_cidr_range = "10.2.0.0/16"
        }
        services_ip_range = {
            range_name = "servicess-range"
            ip_cidr_range = "10.3.0.0/16"
        }
    },
    psc_subnet = {
        name = "<NAME>-dev-psc-subnet"
        ip_cidr_range = "10.0.1.0/24"
        purpose = "PRIVATE_SERVICE_CONNECT"
    },
    proxy_subnet = {
        name = "<NAME>-dev-proxy-subnet"
        ip_cidr_range = "10.0.2.0/24"
        purpose = "REGIONAL_MANAGED_PROXY"
    },
    operations_subnet = {
        name = "<NAME>-dev-operations-subnet",
        ip_cidr_range = "10.0.3.0/24"
    },
    db_subnet = {
        name = "<NAME>-dev-db-subnet",
        ip_cidr_range = "10.0.4.0/24"
    }
}

firewallPolicyInfo = {
    name = "<NAME>-nw-policy"
    description = ""
}

firewallPolicyAssocInfo = {
    name = "<NAME>-nw-policy-assoc"
}

firewallRuleInfo = [
    {
        name = "<NAME>-dev-allow-ssh"
        action = "allow"
        description = ""
        direction = "INGRESS"
        disabled = false
        enable_logging = false
        firewall_policy = ""
        priority = 100
        match = {
            src_ip_ranges = ["0.0.0.0/0"]
            layer4_configs = {
                ip_protocol = "tcp"
                ports = ["22"]
            }
        }
    },
    {
        name = "<NAME>-dev-allow-http(s)"
        action = "allow"
        description = ""
        direction = "INGRESS"
        disabled = false
        enable_logging = true
        firewall_policy = ""
        priority = 101
        match = {
            src_ip_ranges = ["0.0.0.0/0"]
            layer4_configs = {
                ip_protocol = "tcp"
                ports = ["80", "443", "8080"]
            }
        }
    },
    {
        name = "<NAME>-dev-allow-health-check"
        action = "allow"
        description = ""
        direction = "INGRESS"
        disabled = false
        enable_logging = true
        firewall_policy = ""
        priority = 102
        match = {
            src_ip_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
            layer4_configs = {
                ip_protocol = "tcp"
            }
        }
    },
    {
        name = "<NAME>-dev-allow-postgres"
        action = "allow"
        description = ""
        direction = "INGRESS"
        disabled = false
        enable_logging = false
        firewall_policy = ""
        priority = 103
        match = {
            src_ip_ranges = ["0.0.0.0/0"]
            layer4_configs = {
                ip_protocol = "tcp"
                ports = ["5432"]
            }
        }
    },
    {
        name = "<NAME>-dev-allow-egress"
        action = "allow"
        description = ""
        direction = "EGRESS"
        disabled = false
        enable_logging = false
        firewall_policy = ""
        priority = 104
        match = {
            dest_ip_ranges = ["0.0.0.0/0"]
            layer4_configs = {
                ip_protocol = "tcp"
            }
        }
    }
]

lbipInfo = {
    name = "<NAME>-dev-glb-lb-ip"
}

natipInfo = {
    name = "<NAME>-dev-nat-gw-ip"
}

routerInfo  = {
    name = "<NAME>-dev-router"
    routerNAT = {
        name = "<NAME>-dev-router-nat-gw"
    }
}

artifactRegistryInfo = {
    name = "<NAME>-dev-repo"
    description = "<NAME> dev repo"
    format = "DOCKER"
}

sqlInfo = {    
    instanceName = "<PROJECT_ID>-pgsql"
    version = "POSTGRES_14"
    settings = {
        tier = "db-custom-2-8192"
        ipv4_enabled = true
    }
    protection = false
}

dbInfo = [
{
    name = "registry"
    instanceName = "<PROJECT_ID>-pgsql"    
},
{
    name = "keycloak"
    instanceName = "<PROJECT_ID>-pgsql"    
}]

memstoreInfo = {
    name = "<PROJECT_ID>-memstore"
    display_name = "<NAME>-memstore"
    tier  = "BASIC"
    sizeInGB = 1
}

fuseStorageInfo = {
    name = "<NAME>-fuse-stg"
    uniform_bucket_level_access = true
    force_destroy = true
    public_access_prevention = "enforced"
}

opsVMInfo = {
    name = "<PROJECT_ID>-ops-vm"
    ip_name = "<NAME>-opsvm-pub-ip"
    machine_type = "n2d-standard-2"
    zone =  "asia-south1-a"
    boot_disk =  {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
}

secretInfo = {
    name = "<PROJECT_ID>-secret1"
}