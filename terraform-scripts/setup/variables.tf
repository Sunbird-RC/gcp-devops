variable "project_id" {
    type = string
}
variable "service_account" {
    type = string
}
variable "projectInfo"{
    type = object({
        region = string
    })
    
    default = {
        region = "asia-south1"
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


variable "natipInfo" {
    type = object({
        name = string
    })

    default = {
        name = "sunbirdrc-dev-nat-gw-ip"
    }
}