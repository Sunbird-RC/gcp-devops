provider "google" {
    project = var.projectInfo.project
    region = var.projectInfo.region   
}

data "google_service_account" "sa" {
    account_id = var.serviceAccountInfo.id
}

data "google_compute_global_address" "reserved_public_ip" {
    name = var.lbipInfo.name
}

data "google_compute_ssl_certificate" "ssl_cert" {
  name = var.sslCertInfo.name
}

data "google_compute_network_endpoint_group" "negs" {
    count = 3
    name = var.negInfo.name
    project = var.projectInfo.project
    zone = var.negZoneInfo[count.index]    
}

resource "google_compute_health_check" "lb_hc" {
  name = var.hcInfo.name
  check_interval_sec = var.hcInfo.checkInterval
  timeout_sec = var.hcInfo.timeout

  http_health_check {
    request_path = var.hcInfo.request_path
    port = var.hcInfo.port
  }
}

resource "google_compute_backend_service" "lb_bkend" {
    name = var.bkendInfo.name
    project = var.projectInfo.project
    enable_cdn = var.bkendInfo.enable_cdn
    load_balancing_scheme = "EXTERNAL_MANAGED"    
    protocol = "HTTP"
    health_checks = [google_compute_health_check.lb_hc.id]
    backend {      
      balancing_mode = "RATE"
      max_rate_per_endpoint = 80
      group = data.google_compute_network_endpoint_group.negs[0].id
    }
    backend {   
      balancing_mode = "RATE"
      max_rate_per_endpoint = 80   
      group = data.google_compute_network_endpoint_group.negs[1].id
    }
    backend {  
      balancing_mode = "RATE"    
      max_rate_per_endpoint = 80
      group = data.google_compute_network_endpoint_group.negs[2].id
    }
}

resource "google_compute_url_map" "lb_umap" {
  name = var.urlMapInfo.name
  project = var.projectInfo.project
  default_service = google_compute_backend_service.lb_bkend.id
  host_rule {
    hosts = var.urlMapInfo.host_rules[0].hosts
    path_matcher = var.urlMapInfo.host_rules[0].path_matcher
  }
  path_matcher {
    name = var.urlMapInfo.path_matchers[0].name
    default_service = google_compute_backend_service.lb_bkend.id
    path_rule {
      paths = var.urlMapInfo.path_matchers[0].path_rules[0].paths
      service = google_compute_backend_service.lb_bkend.id
    }
  }
  depends_on = [
      google_compute_backend_service.lb_bkend
  ]
}

resource "google_compute_target_https_proxy" "lb_https_proxy" {
  name = var.proxyInfo.name
  project = var.projectInfo.project
  url_map = google_compute_url_map.lb_umap.id
  ssl_certificates = [data.google_compute_ssl_certificate.ssl_cert.id]
  depends_on = [
      google_compute_url_map.lb_umap
  ]
}

resource "google_compute_global_forwarding_rule" "lb_frule" {
  name = var.fwdRuleInfo.name
  project = var.projectInfo.project
  target = google_compute_target_https_proxy.lb_https_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range = "443"
  ip_address = data.google_compute_global_address.reserved_public_ip.id
}

output "lb_public_ip" {
  value = google_compute_global_forwarding_rule.lb_frule.ip_address
}