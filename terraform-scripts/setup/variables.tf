variable "projectInfo"{
    type = object({
        project = string
        region = string
    })
    
    default = {
        project = ""
        region = "asia-south1"
    }
}

variable "serviceAccountInfo" {
    type = object({
        id =  string
    })

    default = {
        id =  "-sa"
    }
}

variable "networkInfo" {
    type = object({
        name =  string
        subnet = string
        opsvmIPName = string
    })

    default = {
        name =  "-vpc"
        subnet = "-gke-subnet"
        opsvmIPName = ""
    }
}

variable "clusterInfo" {
    type = object({
        name = string
        initial_node = number
        deletion_protection = bool
        networking_mode = string
        release_channel = string
        remove_default_pool = bool
        network_policy = bool
        pod_autoscale = bool
        gcsfuse_csi = bool
        private_cluster_config = object({
            enable_private_nodes = bool
            enable_private_endpoint = bool
            master_ipv4_cidr_block = string
            master_global_access_config = bool
        })
        master_authorized_networks_config = object({
            gcp_public_cidrs_access_enabled = bool            
        })        
        nodepool_config = list(object({
            name = string
            machine_type = string
            initial_node = number
            min_node = number
            max_node = number
            max_pods_per_node = number            
        }))
    })

    default = {
        name = "-cluster"
        initial_node = 1
        deletion_protection = false
        networking_mode = "VPC_NATIVE"
        release_channel = "STABLE"
        remove_default_pool = true
        network_policy = true
        pod_autoscale = true
        gcsfuse_csi = true
        private_cluster_config = {
            enable_private_nodes = false
            enable_private_endpoint = false
            master_ipv4_cidr_block = ""
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
            name = "system-pool"            
            machine_type = "e2-medium"
            initial_node = 1
            max_node = 2
            max_pods_per_node = 30
            min_node = 1
        },
        {
            name = "worker-pool"
            machine_type = "n2d-standard-2"
            initial_node = 1
            max_node = 5
            max_pods_per_node = 50
            min_node = 1
        }]
     }
}