
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

variable "aws_profile" {
  default = "default"
}

variable "ami_for_region" {
  type = map(string)
  default = {
    ap-southeast-1 = "ami-02ee763250491e04a"
    ap-southeast-2 = "ami-0e040c48614ad1327"
    us-west-2 = "ami-0d70546e43a941d70"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "spot_price" {
  default = 0.02
}

locals {
  ssh_private_key_file = "local/pki/${var.project}"
}

