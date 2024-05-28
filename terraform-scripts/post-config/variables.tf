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

variable "sslCertInfo" {
    type = object({
        name = string        
    })

    default = {
        name = "-ssl-cert"        
     }
}

variable "networkInfo" {
    type = object({
        name =  string
        subnet = string
    })

    default = {
        name =  "-vpc"
        subnet = "-gke-subnet"
    }
}

variable lbipInfo {
    type = object({
        name = string
    })

    default = {
        name = "-glb-lb-ip"
    }
}

variable "negInfo" {
    type = object({
        name = string
    })

    default = {
        name = ""
     }
}

variable "negZoneInfo" {
    type = list(string)

    default = ["asia-south1-a", "asia-south1-b", "asia-south1-c"]
}

variable "bkendInfo" {
    type = object({
        name = string
        enable_cdn = bool
    })

    default = {
        name = "bkend-service"
        enable_cdn = false
     }
}

variable "hcInfo" {
    type = object({
        name = string
        request_path = string
        port = number
        checkInterval = number
        timeout = number
    })

    default = {
        name = "hcinfo"
        request_path = "/healthz"
        port = 10254
        checkInterval = 5
        timeout = 1
     }
}

variable "urlMapInfo" {
    type = object({
        name = string
        host_rules = list(object({
            hosts = list(string)
            path_matcher = string
        }))
        path_matchers = list(object({
            name = string
            path_rules = list(object({
                paths = list(string)                
            }))
        }))
    })

    default = {
        name = "url-map"
        host_rules = [
        {
            hosts = [""]
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
}

variable "proxyInfo" {
    type = object({
        name = string
    })

    default = {
        name = "https-proxy"
     }
}

variable "fwdRuleInfo" {
    type = object({
        name = string
    })

    default = {
        name = "fwd-rule"
     }
}
