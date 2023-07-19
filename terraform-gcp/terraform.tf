
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.15.0"
    }
  }
}


provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
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

resource "local_file" "ssh_config" {
  content = templatefile("templates/ssh.cfg.tpl", {
    vpn_server_ip = local.vpn_server_public_ip,
    vpn_client_ip = local.vpn_client_public_ip,
    nfs_server_ip = local.nfs_server_ip,
    nfs_cache_ip = local.nfs_cache_ip,
    nfs_client_1_ip = local.nfs_client_1_ip,
    nfs_client_2_ip = local.nfs_client_2_ip,
    prometheus_ip = local.prometheus_ip,
    ssh_username  = var.gcp_username,
    ssh_key_file  = local.ssh_private_key_file
    })

  filename        = "local/ssh.cfg"
  file_permission = "0640"
}

