provider "google" {
    project = var.project_id
    region = var.projectInfo.region   
}

data "google_service_account" "project_sa" {
    account_id = var.service_account
}

data "google_compute_network" "project_vpc" {
  name = var.networkInfo.name
}

data "google_compute_subnetwork" "gke_subnet" {
  name = var.networkInfo.subnet
}

data "google_compute_address" "reserved_nat_public_ip" {
  name = var.natipInfo.name
}

module "cloudbuild_private_pool" {
  source  = "GoogleCloudPlatform/secure-cicd/google//modules/cloudbuild-private-pool"
  version = "1.2.1"
  project_id                = var.project_id
  network_project_id        = var.project_id
  location                  = var.projectInfo.region
  create_cloudbuild_network = true
  private_pool_vpc_name     = "private-build-pool"
}

module "vpn_ha-1" {
  source            = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version           = "~> 4.0"
  project_id        = var.project_id
  region            = var.projectInfo.region
  network           = "private-build-pool"
  name              = "cloudbuild-to-gke"
  peer_gcp_gateway  = module.vpn_ha-2.self_link
  router_asn        = 65001

  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.1"
        asn     = 65002
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.1.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }

    remote-1 = {
      bgp_peer = {
        address = "169.254.2.1"
        asn     = 65002
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.2.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = null
      shared_secret                   = ""
    }

  }
  depends_on = [module.cloudbuild_private_pool]
}

module "vpn_ha-2" {
  source              = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version             = "~> 4.0"
  project_id          = var.project_id
  region              = var.projectInfo.region
  network             = data.google_compute_network.project_vpc.name
  name                = "gke-to-cloudbuild"
  router_asn          = 65002
  peer_gcp_gateway    = module.vpn_ha-1.self_link

  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.1.2"
        asn     = 65001
      }
      bgp_session_range               = "169.254.1.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      shared_secret                   = module.vpn_ha-1.random_secret
    }

    remote-1 = {
      bgp_peer = {
        address = "169.254.2.2"
        asn     = 65001
      }
      bgp_session_range               = "169.254.2.1/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      shared_secret                   = module.vpn_ha-1.random_secret
    }

  }
  depends_on = [module.cloudbuild_private_pool]
}

