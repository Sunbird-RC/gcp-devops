projectInfo = {
    region = "asia-south1"
}

networkInfo = {
    name = "functional-registry-vpc"
    auto_create_subnetworks = false
    mtu = 1460
    gke_subnet = {
        name = "functional-registry-gke-subnet"
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
        name = "functional-registry-psc-subnet"
        ip_cidr_range = "10.0.1.0/24"
        purpose = "PRIVATE_SERVICE_CONNECT"
    },
    proxy_subnet = {
        name = "functional-registry-proxy-subnet"
        ip_cidr_range = "10.0.2.0/24"
        purpose = "REGIONAL_MANAGED_PROXY"
    },
    operations_subnet = {
        name = "functional-registry-operations-subnet",
        ip_cidr_range = "10.0.3.0/24"
    },
    db_subnet = {
        name = "functional-registry-db-subnet",
        ip_cidr_range = "10.0.4.0/24"
    }
}

firewallPolicyInfo = {
    name = "functional-registry-nw-policy"
    description = ""
}

firewallPolicyAssocInfo = {
    name = "functional-registry-nw-policy-assoc"
}

firewallRuleInfo = [
    {
        name = "functional-registry-allow-ssh"
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
        name = "functional-registry-allow-http(s)"
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
        name = "functional-registry-allow-health-check"
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
        name = "functional-registry-allow-postgres"
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
        name = "functional-registry-allow-egress"
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
    name = "functional-registry-glb-lb-ip"
}

sql_ip_name = "functional-registry-sql-lb-ip"

natipInfo = {
    name = "functional-registry-nat-gw-ip"
}

routerInfo  = {
    name = "functional-registry-router"
    routerNAT = {
        name = "functional-registry-router-nat-gw"
    }
}

artifactRegistryInfo = {
    name = "functional-registry-repo"
    description = "functional-registry repo"
    format = "DOCKER"
}

sqlInfo = {    
    instanceName = "functional-registry-pgsql"
    version = "POSTGRES_14"
    settings = {
        tier = "db-custom-2-8192"
        ipv4_enabled = false
    }
    protection = false
}

dbInfo = [
{
    name = "registry"
    instanceName = "functional-registry-pgsql"
},
{
    name = "keycloak"
    instanceName = "functional-registry-pgsql"
}]

memstoreInfo = {
    name = "functional-registry-memstore"
    display_name = "functional-registry-memstore"
    tier  = "BASIC"
    sizeInGB = 1
}

fuseStorageInfo = {
    name = "functional-registry-fuse-stg"
    uniform_bucket_level_access = true
    force_destroy = true
    public_access_prevention = "enforced"
}

opsVMInfo = {
    name = "functional-registry-ops-vm"
    ip_name = "functional-registry-opsvm-pub-ip"
    machine_type = "n2d-standard-2"
    zone =  "asia-south1-a"
    boot_disk =  {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
}

secretInfo = {
    name = "functional-registry-secret1"
}