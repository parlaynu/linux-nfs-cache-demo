## render the run script

resource "local_file" "run_playbook" {
  content = templatefile("templates/ansible/run-ansible.sh.tpl", {
      inventory_file = "inventory.ini"
    })
  filename = "local/ansible/run-ansible.sh"
  file_permission = "0755"
}


## render the playbook

resource "local_file" "playbook" {
  content = templatefile("templates/ansible/playbook.yml.tpl", {
    gateway_role = local.gateway_role,
    wireguard_server_role = local.wireguard_server_role,
    wireguard_client_role = local.wireguard_client_role,
    prometheus_role = local.prometheus_role,
    prometheus_node_role = local.prometheus_node_role,
    nfs_server_role = local.nfs_server_role,
    nfs_cache_role = local.nfs_cache_role,
    nfs_client_ubuntu_role = local.nfs_client_ubuntu_role,
    nfs_client_centos_role = local.nfs_client_centos_role,
    fsutils_ubuntu_role = local.fsutils_ubuntu_role,
    fsutils_centos_role = local.fsutils_centos_role,
  })
  filename = "local/ansible/playbook.yml"
}


## render host variables

resource "local_file" "hostvars_vpn_server" {

  content = templatefile("templates/ansible/hostvars-vpn-server.yml.tpl", {
    server_name      = "vpn-server",
    public_ip        = local.vpn_server_public_ip,
    private_ip       = local.vpn_server_ip

    iface_name       = "ens4"
    local_cidr_block  = var.server_site.cidr_block
    remote_cidr_block = var.client_site.cidr_block

    vpn_cidr_block   = var.vpn_cidr_block
    vpn_netlen       = split("/", var.vpn_cidr_block)[1]
    vpn_ip           = cidrhost(var.vpn_cidr_block, var.server_site.vpn_hostnum)
    vpn_private_key  = var.server_site.vpn_private_key,
    vpn_listen_port  = var.vpn_port
    
    peers = [
      {
        name = "vpn-client"
        cidr_block = var.client_site.cidr_block
        public_ip = local.vpn_client_public_ip
        private_ip = local.vpn_client_ip
        vpn_public_key = var.client_site.vpn_public_key
        vpn_ip = cidrhost(var.vpn_cidr_block, var.client_site.vpn_hostnum)
      }
    ]
  })

  filename        = "local/ansible/host_vars/vpn-server.yml"
  file_permission = "0640"
}

resource "local_file" "hostvars_vpn_client" {

  content = templatefile("templates/ansible/hostvars-vpn-client.yml.tpl", {
    server_name      = "vpn-client",
    public_ip        = local.vpn_client_public_ip,
    private_ip       = local.vpn_client_ip
    
    iface_name       = "ens4"
    local_cidr_block  = var.client_site.cidr_block
    remote_cidr_block = var.server_site.cidr_block

    vpn_cidr_block   = var.vpn_cidr_block
    vpn_netlen       = split("/", var.vpn_cidr_block)[1]
    vpn_ip           = cidrhost(var.vpn_cidr_block, var.client_site.vpn_hostnum)
    vpn_private_key  = var.client_site.vpn_private_key,

    peers = [
      {
        name = "vpn-server"
        cidr_block = var.server_site.cidr_block
        public_ip = local.vpn_server_public_ip
        private_ip = local.vpn_server_ip
        vpn_public_key = var.server_site.vpn_public_key
        vpn_ip = cidrhost(var.vpn_cidr_block, var.server_site.vpn_hostnum)
        vpn_listen_port = var.vpn_port
      }
    ]
  })

  filename        = "local/ansible/host_vars/vpn-client.yml"
  file_permission = "0640"
}


resource "local_file" "hostvars_prometheus" {

  content = templatefile("templates/ansible/hostvars-prometheus.yml.tpl", {
    server_name = "prometheus",
    private_ip  = local.vpn_client_ip
    nodes       = local.all_ubuntu
  })

  filename        = "local/ansible/host_vars/prometheus.yml"
  file_permission = "0640"
}


resource "local_file" "nfs_server" {
  content = templatefile("templates/ansible/hostvars-nfs-server.yml.tpl", {
    server_name      = "nfs-server",
    private_ip       = local.nfs_server_ip,
    external_disk_id = local.nfs_server_disk_id,
    export_client    = local.nfs_cache_ip,
  })

  filename        = "local/ansible/host_vars/nfs-server.yml"
  file_permission = "0640"
}


resource "local_file" "nfs_cache" {
  content = templatefile("templates/ansible/hostvars-nfs-cache.yml.tpl", {
    server_name = "nfs-cache",
    private_ip   = local.nfs_cache_ip,
    external_disk_id = local.nfs_cache_disk_id,
    export_client = var.client_site.cidr_block,
    nfs_server = local.nfs_server_ip
    export_fs_uuid = uuidv5("url", "http://${local.nfs_cache_ip}/")
  })

  filename        = "local/ansible/host_vars/nfs-cache.yml"
  file_permission = "0640"
}

resource "local_file" "nfs_clients" {
  for_each = local.nfs_clients
  
  content = templatefile("templates/ansible/hostvars-nfs-client.yml.tpl", {
    server_name = replace(each.key, "_", "-"),
    private_ip   = each.value
    nfs_server   = local.nfs_cache_ip
  })

  filename        = "local/ansible/host_vars/${replace(each.key, "_", "-")}.yml"
  file_permission = "0640"
}

## render the inventory file

resource "local_file" "inventory" {
  content = templatefile("templates/ansible/inventory.ini.tpl", {})
  filename = "local/ansible/inventory.ini"
}
