## convenience variables

locals {
  vpn_client_public_ip = google_compute_instance.vpn_client.network_interface.0.access_config.0.nat_ip 
  vpn_client_ip = google_compute_instance.vpn_client.network_interface.0.network_ip 
  nfs_cache_ip = google_compute_instance.nfs_cache.network_interface.0.network_ip 
  nfs_client_1_ip = google_compute_instance.nfs_client_1.network_interface.0.network_ip 
  nfs_client_2_ip = google_compute_instance.nfs_client_2.network_interface.0.network_ip 
  
  nfs_clients = {
    nfs_client_1 = google_compute_instance.nfs_client_1.network_interface.0.network_ip 
    nfs_client_2 = google_compute_instance.nfs_client_2.network_interface.0.network_ip 
  }
}


## the network

resource "google_compute_network" "client_network" {
  name = "${var.client_site.name}"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "client_subnet_0" {
  name          = "${var.client_site.name}-sub0"
  network       = google_compute_network.client_network.id
  region        = var.client_site.region
  ip_cidr_range = var.client_site.cidr_block
}


resource "google_compute_firewall" "client_firewall_internal" {
  name    = "${var.client_site.name}-internal"
  network = google_compute_network.client_network.id

  allow {
    protocol = "icmp"
  }
  allow {
   protocol = "ipip"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    google_compute_subnetwork.client_subnet_0.ip_cidr_range
  ]
}


resource "google_compute_firewall" "client_firewall_server" {
  name    = "${var.client_site.name}-server"
  network = google_compute_network.client_network.id

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    google_compute_subnetwork.server_subnet_0.ip_cidr_range
  ]
}


resource "google_compute_firewall" "client_firewall_ssh" {
  name    = "${var.client_site.name}-ssh"
  network = google_compute_network.client_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
}


resource "google_compute_route" "client_default_0" {
  name        = "${var.client_site.name}-default-0"
  network     = google_compute_network.client_network.id
  dest_range  = "0.0.0.0/1"
  next_hop_ip = local.vpn_client_ip
  priority    = 100
  tags        = ["client"]
}


resource "google_compute_route" "client_default_1" {
  name        = "${var.client_site.name}-default-1"
  network     = google_compute_network.client_network.id
  dest_range  = "128.0.0.0/1"
  next_hop_ip = local.vpn_client_ip
  priority    = 100
  tags        = ["client"]
}


## vpn client

resource "google_compute_instance" "vpn_client" {
  name         = "vpn-client"
  machine_type = var.instance_type
  zone         = var.client_site.zone
  
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet_0.self_link
    
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
}


## nfs cache

locals {
  nfs_cache_disk_name = "cache"
  nfs_cache_disk_id = "google-${local.nfs_cache_disk_name}"
}

resource "google_compute_instance" "nfs_cache" {
  name         = "nfs-cache"
  machine_type = var.instance_type
  zone         = var.client_site.zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  
  attached_disk {
    source      = google_compute_disk.nfs_cache_cache.self_link
    device_name = local.nfs_cache_disk_name
  }

  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet_0.self_link
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
  
  tags = ["client"]
}

resource "google_compute_disk" "nfs_cache_cache" {
  name  = "nfs-cache-cache"
  zone  = var.client_site.zone
  type  = "pd-standard"
  size  = 20
  physical_block_size_bytes = 4096
}


## nfs client

resource "google_compute_instance" "nfs_client_1" {
  name         = "nfs-client-1"
  machine_type = var.instance_type
  zone         = var.client_site.zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet_0.self_link
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
  
  tags = ["client"]
}


## nfs client - centos

resource "google_compute_instance" "nfs_client_2" {
  name         = "nfs-client-2"
  machine_type = var.instance_type
  zone         = var.client_site.zone
  
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.client_subnet_0.self_link
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
  
  tags = ["client"]
}

