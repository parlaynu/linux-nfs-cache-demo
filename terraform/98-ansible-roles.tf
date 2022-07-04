## local variables

locals {
  all_servers = {
    vpn_server = data.aws_instance.vpn_server
    vpn_client = data.aws_instance.vpn_client
    prometheus = data.aws_instance.prometheus
    nfs_server = data.aws_instance.nfs_server
    nfs_cache = data.aws_instance.nfs_cache
    nfs_client = data.aws_instance.nfs_client
  }

  private_servers = {
    nfs_server = data.aws_instance.nfs_server
    nfs_cache = data.aws_instance.nfs_cache
    nfs_client = data.aws_instance.nfs_client
  }
}


locals {
  gateway_role = "gateway"
  wireguard_server_role = "wireguard_server"
  wireguard_client_role = "wireguard_client"
  prometheus_role = "prometheus"
  prometheus_node_role = "prometheus_node"
  nfs_server_role = "nfs_server"
  nfs_cache_role = "nfs_cache"
  nfs_client_role = "nfs_client"
  fsutils_role = "fsutils"
}


resource "template_dir" "gateway" {
  source_dir = "templates/ansible-roles/${local.gateway_role}"
  destination_dir = "local/ansible/roles/${local.gateway_role}"
  
  vars = {}
}


resource "template_dir" "wireguard_server" {
  source_dir = "templates/ansible-roles/${local.wireguard_server_role}"
  destination_dir = "local/ansible/roles/${local.wireguard_server_role}"
  
  vars = {}
}


resource "template_dir" "wireguard_client" {
  source_dir = "templates/ansible-roles/${local.wireguard_client_role}"
  destination_dir = "local/ansible/roles/${local.wireguard_client_role}"
  
  vars = {}
}


resource "template_dir" "prometheus" {
  source_dir = "templates/ansible-roles/${local.prometheus_role}"
  destination_dir = "local/ansible/roles/${local.prometheus_role}"
  
  vars = {}
}


resource "template_dir" "prometheus_node" {
  source_dir = "templates/ansible-roles/${local.prometheus_node_role}"
  destination_dir = "local/ansible/roles/${local.prometheus_node_role}"
  
  vars = {}
}


resource "template_dir" "nfs_server" {
  source_dir = "templates/ansible-roles/${local.nfs_server_role}"
  destination_dir = "local/ansible/roles/${local.nfs_server_role}"
  
  vars = {}
}


resource "template_dir" "nfs_cache" {
  source_dir = "templates/ansible-roles/${local.nfs_cache_role}"
  destination_dir = "local/ansible/roles/${local.nfs_cache_role}"

  vars = {}
}


resource "template_dir" "nfs_client" {
  source_dir = "templates/ansible-roles/${local.nfs_client_role}"
  destination_dir = "local/ansible/roles/${local.nfs_client_role}"

  vars = {}
}


resource "template_dir" "fsutils" {
  source_dir = "templates/ansible-roles/${local.fsutils_role}"
  destination_dir = "local/ansible/roles/${local.fsutils_role}"

  vars = {}
}
