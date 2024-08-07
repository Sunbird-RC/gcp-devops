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
    operations_subnet = {
        name = "functional-registry-operations-subnet",
        ip_cidr_range = "10.0.3.0/24"
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
                ports = ["80", "443"]
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
    version = "POSTGRES_16"
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
},
{
    name = "credentials"
    instanceName = "functional-registry-pgsql"
},
{
    name = "credential-schema"
    instanceName = "functional-registry-pgsql"
},
{
    name = "identity"
    instanceName = "functional-registry-pgsql"
}
]


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
    name = "registry"
}

clusterInfo = {
    name = "functional-registry-cluster"
    initial_node = 1
    deletion_protection = false
    networking_mode = "VPC_NATIVE"
    release_channel = "UNSPECIFIED"
    remove_default_pool = true
    network_policy = true
    pod_autoscale = true
    gcsfuse_csi = true
    private_cluster_config = null
    master_authorized_networks_config = null

    private_cluster_config = {
        enable_private_nodes = true
        enable_private_endpoint = false
        master_ipv4_cidr_block = "10.0.6.0/28"
        master_global_access_config = false
    }
    master_authorized_networks_config = {
        gcp_public_cidrs_access_enabled = false
    }

    nodepool_config = [
        {
            name = "worker-pool"
            machine_type = "n2d-standard-4"
            initial_node = 1
            max_node = 5
            max_pods_per_node = 50
            min_node = 1
        }]
}