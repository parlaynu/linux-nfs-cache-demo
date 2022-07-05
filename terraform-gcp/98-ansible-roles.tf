## local variables

locals {
  all_ubuntu = {
    vpn_server = local.vpn_server_ip
    vpn_client = local.vpn_client_ip
    prometheus = local.prometheus_ip
    nfs_server = local.nfs_server_ip
    nfs_cache = local.nfs_cache_ip
    nfs_client_1 = local.nfs_client_1_ip
  }

  all_centos = {
    nfs_client_2 = local.nfs_client_2_ip
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
  nfs_client_ubuntu_role = "nfs_client_ubuntu"
  nfs_client_centos_role = "nfs_client_centos"
  fsutils_ubuntu_role = "fsutils_ubuntu"
  fsutils_centos_role = "fsutils_centos"
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


resource "template_dir" "nfs_client_ubuntu" {
  source_dir = "templates/ansible-roles/${local.nfs_client_ubuntu_role}"
  destination_dir = "local/ansible/roles/${local.nfs_client_ubuntu_role}"

  vars = {}
}


resource "template_dir" "nfs_client_centos" {
  source_dir = "templates/ansible-roles/${local.nfs_client_centos_role}"
  destination_dir = "local/ansible/roles/${local.nfs_client_centos_role}"

  vars = {}
}


resource "template_dir" "fsutils_ubuntu" {
  source_dir = "templates/ansible-roles/${local.fsutils_ubuntu_role}"
  destination_dir = "local/ansible/roles/${local.fsutils_ubuntu_role}"

  vars = {}
}


resource "template_dir" "fsutils_centos" {
  source_dir = "templates/ansible-roles/${local.fsutils_centos_role}"
  destination_dir = "local/ansible/roles/${local.fsutils_centos_role}"

  vars = {}
}
