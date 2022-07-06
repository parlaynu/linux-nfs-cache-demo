terraform {  
  required_providers {    
    aws = {      
      source  = "hashicorp/aws"      
      version = "~> 4.19"
    }
  }
  required_version = ">= 1.2.3"
}

provider "aws" {
  profile = var.aws_profile
  region = var.server_site.region
}

provider "aws" {
  alias = "client"
  profile = var.aws_profile
  region = var.client_site.region
}


## my public ip address - allow ssh from this address
data "external" "my_public_ip" {
  program = ["../scripts/my-public-ip.sh"]
}


## ssh configuration
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = local.ssh_private_key_file
  file_permission = "0600"
}

resource "aws_key_pair" "ssh_key_server" {
  key_name   = var.project
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_key_pair" "ssh_key_client" {
  provider = aws.client
  key_name   = var.project
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_config" {
  content = templatefile("templates/ssh.cfg.tpl", {
    vpn_server = data.aws_instance.vpn_server,
    vpn_client = data.aws_instance.vpn_client,
    nfs_server = data.aws_instance.nfs_server,
    nfs_cache = data.aws_instance.nfs_cache,
    nfs_client = data.aws_instance.nfs_client,
    prometheus = data.aws_instance.prometheus,
    ssh_username  = "ubuntu",
    ssh_key_file  = local.ssh_private_key_file
    })

  filename        = "local/ssh.cfg"
  file_permission = "0640"
}

