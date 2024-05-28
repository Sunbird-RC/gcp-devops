projectInfo = {
    project = "<PROJECT_ID>"
        region = "asia-south1"
    
}

serviceAccountInfo = {
    id =  "<PROJECT_ID>-sa"
}

networkInfo = {
    name =  "<NAME>-dev-vpc"
    subnet = "<NAME>-dev-gke-subnet"
}

sslCertInfo = {
    name = "<PROJECT_ID>-ssl-cert"    
}

lbipInfo = {
    name = "<NAME>-dev-glb-lb-ip"
}

negInfo = {
    name = "<NAME>-dev-nginx-80-neg"
}

negZoneInfo = ["asia-south1-a", "asia-south1-b", "asia-south1-c"]

bkendInfo = {
    name = "<NAME>-bkend-service"
    enable_cdn = false
}

hcInfo = {
    name = "<NAME>-hcinfo"
    request_path = "/healthz"
    port = 10254
    checkInterval = 5
    timeout = 1
}

urlMapInfo = {
     name = "<NAME>-url-map"
    host_rules = [
    {
        hosts = ["<NAME>.gcpwkshpdev.com"]
        path_matcher = "default"
    }]
    path_matchers = [
    {
        name = "default"
        path_rules = [
        {
            paths = ["/*"]
        }]
    }]
}

proxyInfo = {
    name = "<NAME>-https-proxy"
}

fwdRuleInfo = {
    name = "<NAME>-fwd-rule"
}
