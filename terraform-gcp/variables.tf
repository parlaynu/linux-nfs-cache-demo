variable "project_id" {
  default = ""
}

variable "credentials_file" {
  default = ""
}

variable "gcp_username" {
  default = ""
}

variable "project" {
  default = "nfscache"
}

variable "server_site" {
  type = object({
    name = string,
    region = string,
    zone = string,
    cidr_block = string,
    vpn_hostnum = number,
    vpn_private_key = string,
    vpn_public_key = string
    })
  default = {
    name = "server"
    region = "ap-southeast-2"
    zone = "ap-southeast-2c"
    cidr_block = "192.168.100.0/24"
    vpn_hostnum     = 100
    vpn_private_key = ""
    vpn_public_key  = ""
  }
}

variable "client_site" {
  type = object({
    name = string,
    region = string,
    zone = string,
    cidr_block = string,
    vpn_hostnum = number,
    vpn_private_key = string,
    vpn_public_key = string
    })
  default = {
    name = "client"
    region = ""
    zone = ""
    cidr_block = "192.168.101.0/24"
    vpn_hostnum     = 101
    vpn_private_key = ""
    vpn_public_key  = ""
  }
}

variable "vpn_cidr_block" {
  default = "192.168.99.0/24"
}

variable "vpn_port" {
  default = 51820
}

variable "instance_type" {
  default = "e2-medium"
}

locals {
  ssh_private_key_file = "local/pki/${var.project}"
}
