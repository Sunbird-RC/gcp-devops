provider "google" {
    project = var.projectInfo.project
    region = var.projectInfo.region   
}

data "google_service_account" "project_sa" {
    account_id = var.serviceAccountInfo.id
}

data "google_compute_network" "project_vpc" {
  name = var.networkInfo.name
}

data "google_compute_subnetwork" "gke_subnet" {
  name = var.networkInfo.subnet
}

data "google_compute_address" "reserved_opsvm_public_ip" {
  name = var.networkInfo.opsvmIPName
}

resource "google_container_cluster" "gke_cluster" {
    name = var.clusterInfo.name
    project = var.projectInfo.project
    location = var.projectInfo.region
    release_channel {
      channel = var.clusterInfo.release_channel
    }
    initial_node_count = var.clusterInfo.initial_node
    deletion_protection = false
    remove_default_node_pool = var.clusterInfo.remove_default_pool
    networking_mode = var.clusterInfo.networking_mode
    network = data.google_compute_network.project_vpc.name
    subnetwork = data.google_compute_subnetwork.gke_subnet.name

    dynamic private_cluster_config {
      for_each = (var.clusterInfo.private_cluster_config == null) ? [] : [1]
      content {
        enable_private_nodes = var.clusterInfo.private_cluster_config.enable_private_nodes
        enable_private_endpoint = var.clusterInfo.private_cluster_config.enable_private_endpoint
        master_ipv4_cidr_block = var.clusterInfo.private_cluster_config.master_ipv4_cidr_block
        master_global_access_config {
          enabled = var.clusterInfo.private_cluster_config.master_global_access_config
        }
      }
    }
    dynamic master_authorized_networks_config {
      for_each = (var.clusterInfo.master_authorized_networks_config == null) ? [] : [1]
      content {
        gcp_public_cidrs_access_enabled = var.clusterInfo.master_authorized_networks_config.gcp_public_cidrs_access_enabled
        cidr_blocks {
          cidr_block = "${data.google_compute_address.reserved_opsvm_public_ip.address}/32"
        }
      }
    }
    ip_allocation_policy {
      cluster_secondary_range_name = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[0].range_name
      services_secondary_range_name = data.google_compute_subnetwork.gke_subnet.secondary_ip_range[1].range_name
    }
    network_policy {
      enabled = var.clusterInfo.network_policy
    }
    workload_identity_config {
      workload_pool = "${var.projectInfo.project}.svc.id.goog"
    }
    addons_config {
      horizontal_pod_autoscaling {
        disabled = !var.clusterInfo.pod_autoscale
      }

      gcs_fuse_csi_driver_config {
        enabled = var.clusterInfo.gcsfuse_csi
      }
    }   

    authenticator_groups_config {
      security_group = "gke-security-groups@monojitdatta.altostrat.com"
    } 
}

resource "google_container_node_pool" "system_pool" {
    name = var.clusterInfo.nodepool_config[0].name
    project = var.projectInfo.project
    cluster = google_container_cluster.gke_cluster.id
    initial_node_count = var.clusterInfo.nodepool_config[0].initial_node
    node_config {
      service_account = data.google_service_account.project_sa.email
      machine_type = var.clusterInfo.nodepool_config[0].machine_type
    }    
    autoscaling {
      min_node_count = var.clusterInfo.nodepool_config[0].min_node
      max_node_count = var.clusterInfo.nodepool_config[0].max_node  
    }
    max_pods_per_node = var.clusterInfo.nodepool_config[0].max_pods_per_node
}

resource "google_container_node_pool" "worker_pool" {
    name = var.clusterInfo.nodepool_config[1].name
    project = var.projectInfo.project
    cluster = google_container_cluster.gke_cluster.id
    initial_node_count = var.clusterInfo.nodepool_config[1].initial_node
    node_config {
      service_account = data.google_service_account.project_sa.email
      machine_type = var.clusterInfo.nodepool_config[1].machine_type
    }
    autoscaling {
      min_node_count = var.clusterInfo.nodepool_config[1].min_node
      max_node_count = var.clusterInfo.nodepool_config[1].max_node  
    }
    max_pods_per_node = var.clusterInfo.nodepool_config[1].max_pods_per_node
}