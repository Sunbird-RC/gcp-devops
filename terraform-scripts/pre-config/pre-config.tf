provider "google" {
    project = var.projectInfo.project
    region = var.projectInfo.region   
}

data "google_service_account" "sa" {
  account_id = var.serviceAccountInfo.name
}

resource "google_compute_network" "vpc" {
    name = var.networkInfo.name
    project = var.projectInfo.project
    auto_create_subnetworks = var.networkInfo.auto_create_subnetworks
    mtu = var.networkInfo.mtu  
}

resource "google_compute_subnetwork" "gke_subnet" {
    name = var.networkInfo.gke_subnet.name
    project = var.projectInfo.project
    region = var.projectInfo.region
    network = google_compute_network.vpc.id
    ip_cidr_range = var.networkInfo.gke_subnet.ip_cidr_range
    # secondary_ip_range = [{
    #     range_name = var.networkInfo.gke_subnet.pods_ip_range.range_name
    #     ip_cidr_range = var.networkInfo.gke_subnet.pods_ip_range.ip_cidr_range      
    # },
    # {
    #     range_name = var.networkInfo.gke_subnet.services_ip_range.range_name
    #     ip_cidr_range = var.networkInfo.gke_subnet.services_ip_range.ip_cidr_range
    # }]
    depends_on = [
        google_compute_network.vpc
    ]
}

resource "google_compute_subnetwork" "proxy_subnet" {
    name = var.networkInfo.proxy_subnet.name
    project = var.projectInfo.project
    region = var.projectInfo.region
    network = google_compute_network.vpc.id
    ip_cidr_range = var.networkInfo.proxy_subnet.ip_cidr_range
    depends_on = [
        google_compute_network.vpc
    ]
}

resource "google_compute_subnetwork" "psc_subnet" {
    name = var.networkInfo.psc_subnet.name
    project = var.projectInfo.project
    region = var.projectInfo.region
    network = google_compute_network.vpc.id
    ip_cidr_range = var.networkInfo.psc_subnet.ip_cidr_range
    depends_on = [
        google_compute_network.vpc
    ]
}

resource "google_compute_subnetwork" "operations_subnet" {
    name = var.networkInfo.operations_subnet.name
    project = var.projectInfo.project
    region = var.projectInfo.region
    network = google_compute_network.vpc.id
    ip_cidr_range = var.networkInfo.operations_subnet.ip_cidr_range
    depends_on = [
        google_compute_network.vpc
    ]
}

resource "google_compute_subnetwork" "db_subnet" {
    name = var.networkInfo.db_subnet.name
    project = var.projectInfo.project
    region = var.projectInfo.region
    network = google_compute_network.vpc.id
    ip_cidr_range = var.networkInfo.db_subnet.ip_cidr_range
    depends_on = [
        google_compute_network.vpc
    ]
}

resource "google_compute_network_firewall_policy" "fw_policy" {
  name = var.firewallPolicyInfo.name
  project = var.projectInfo.project
  description = var.firewallPolicyInfo.description
}

resource "google_compute_network_firewall_policy_association" "fw_policy_assoc" {
  name = var.firewallPolicyAssocInfo.name
  project = var.projectInfo.project
  attachment_target = google_compute_network.vpc.id
  firewall_policy = google_compute_network_firewall_policy.fw_policy.name
}

resource "google_compute_network_firewall_policy_rule" "fw_rules" {
  count = 5
  action = var.firewallRuleInfo[count.index].action
  description = var.firewallRuleInfo[count.index].description
  direction = var.firewallRuleInfo[count.index].direction
  disabled = var.firewallRuleInfo[count.index].disabled
  enable_logging = var.firewallRuleInfo[count.index].enable_logging
  firewall_policy = google_compute_network_firewall_policy.fw_policy.name
  priority = var.firewallRuleInfo[count.index].priority
  rule_name = var.firewallRuleInfo[count.index].name

  match {
    src_ip_ranges = var.firewallRuleInfo[count.index].match.src_ip_ranges
    dest_ip_ranges = var.firewallRuleInfo[count.index].match.dest_ip_ranges
    layer4_configs {
        ip_protocol = var.firewallRuleInfo[count.index].match.layer4_configs.ip_protocol
        ports = var.firewallRuleInfo[count.index].match.layer4_configs.ports
    }
  }
}

resource "google_compute_global_address" "reserved_lb_public_ip" {
  name = var.lbipInfo.name
}

resource "google_compute_address" "reserved_ngw_public_ip" {
  name = var.natipInfo.name
}

resource "google_compute_address" "reserved_opsvm_public_ip" {
  name = var.opsVMInfo.ip_name
}

resource "google_compute_router" "router" {
  name = var.routerInfo.name
  region = var.projectInfo.region
  network = var.networkInfo.name
  depends_on = [google_compute_network.vpc]
}

resource "google_compute_router_nat" "nat_router" {
  name = var.routerInfo.routerNAT.name
  router = google_compute_router.router.name
  region = var.projectInfo.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [google_compute_address.reserved_ngw_public_ip.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name = google_compute_subnetwork.gke_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  depends_on = [google_compute_router.router]
}

resource "google_artifact_registry_repository" "artifact_registry" {
    location = var.projectInfo.region
    repository_id = var.artifactRegistryInfo.name
    description = var.artifactRegistryInfo.description
    format = var.artifactRegistryInfo.format
}

resource "google_sql_database_instance" "db_instance" {  
  name = var.sqlInfo.instanceName
  region = var.projectInfo.region
  database_version = var.sqlInfo.version
  settings {
    tier = var.sqlInfo.settings.tier
    ip_configuration {
        ipv4_enabled = var.sqlInfo.settings.ipv4_enabled
        authorized_networks {
          name = "allow-nat-gw-ip"
          value = google_compute_address.reserved_ngw_public_ip.address
        }
    }
  }
  deletion_protection = var.sqlInfo.protection
}

resource "google_sql_database" "db" {
  count = 2
  name = var.dbInfo[count.index].name
  instance = var.dbInfo[count.index].instanceName
  depends_on = [google_sql_database_instance.db_instance]
}

resource "google_redis_instance" "redis" {
  name = var.memstoreInfo.name
  display_name = var.memstoreInfo.display_name
  memory_size_gb = 1

  authorized_network = google_compute_network.vpc.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket" "fuse_bucket" {
  name = var.fuseStorageInfo.name
  location = var.projectInfo.region
  force_destroy = var.fuseStorageInfo.force_destroy
  public_access_prevention = var.fuseStorageInfo.public_access_prevention
  uniform_bucket_level_access = var.fuseStorageInfo.uniform_bucket_level_access
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = var.fuseStorageInfo.name
  role = "roles/storage.admin"
  members = [
    "serviceAccount:${data.google_service_account.sa.email}"
  ]
  depends_on = [google_storage_bucket.fuse_bucket]
}

resource "google_compute_instance" "operations_vm" {
  name = var.opsVMInfo.name
  machine_type = var.opsVMInfo.machine_type
  zone = var.opsVMInfo.zone
  tags = var.opsVMInfo.tags  
  boot_disk {
    initialize_params {
      image = var.opsVMInfo.boot_disk.image
    }
  }
  network_interface {
    network = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.operations_subnet.id
    access_config {
      nat_ip = google_compute_address.reserved_opsvm_public_ip.address
    }
  }
  service_account {
    email = data.google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
}

resource "google_secret_manager_secret" "secret_basic" {
  secret_id = var.secretInfo.name

  replication {
    auto {
      
    }

  }
}

resource "google_secret_manager_secret_iam_binding" "secret_iam_binding" {
  project = google_secret_manager_secret.secret_basic.project
  secret_id = google_secret_manager_secret.secret_basic.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${data.google_service_account.sa.email}",
  ]
}

output "lb_public_ip" {
  value = google_compute_global_address.reserved_lb_public_ip.address
}

output "ngw_public_ip" {
  value = google_compute_address.reserved_ngw_public_ip.address
}

output "opsvm_public_ip" {
  value = google_compute_address.reserved_opsvm_public_ip.address
}

output "sql_public_ip" {
  value = google_sql_database_instance.db_instance.ip_address.0.ip_address
}