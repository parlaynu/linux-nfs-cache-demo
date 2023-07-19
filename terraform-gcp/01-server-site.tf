## convenience variables

locals {
  vpn_server_public_ip = google_compute_instance.vpn_server.network_interface.0.access_config.0.nat_ip 
  vpn_server_ip = google_compute_instance.vpn_server.network_interface.0.network_ip 
  nfs_server_ip = google_compute_instance.nfs_server.network_interface.0.network_ip 
}


## the network

resource "google_compute_network" "server_network" {
  name = "${var.server_site.name}"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "server_subnet_0" {
  name          = "${var.server_site.name}-sub0"
  network       = google_compute_network.server_network.id
  region        = var.server_site.region
  ip_cidr_range = var.server_site.cidr_block
}


resource "google_compute_firewall" "server_firewall_internal" {
  name    = "${var.server_site.name}-internal"
  network = google_compute_network.server_network.id

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
    google_compute_subnetwork.server_subnet_0.ip_cidr_range
  ]
}


resource "google_compute_firewall" "server_firewall_client" {
  name    = "${var.server_site.name}-client"
  network = google_compute_network.server_network.id

  allow {
    protocol = "icmp"
  }
  # nfs server, prometheus node exporter
  allow {
    protocol = "tcp"
    ports    = ["2049", "9100"]
  }
  # nfs server
  allow {
    protocol = "udp"
    ports    = ["2049"]
  }

  source_ranges = [
    google_compute_subnetwork.client_subnet_0.ip_cidr_range
  ]
}


resource "google_compute_firewall" "server_firewall_ssh" {
  name    = "${var.server_site.name}-ssh"
  network = google_compute_network.server_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
}


resource "google_compute_firewall" "server_firewall_vpn" {
  name    = "${var.server_site.name}-vpn"
  network = google_compute_network.server_network.id

  allow {
    protocol = "udp"
    ports    = [var.vpn_port]
  }
  
  source_ranges = ["${local.vpn_client_public_ip}/32"]
}


resource "google_compute_route" "server_default_0" {
  name        = "${var.server_site.name}-default-0"
  network     = google_compute_network.server_network.id
  dest_range  = "0.0.0.0/1"
  next_hop_ip = local.vpn_server_ip
  priority    = 100
  tags        = ["server"]
}


resource "google_compute_route" "server_default_1" {
  name        = "${var.server_site.name}-default-1"
  network     = google_compute_network.server_network.id
  dest_range  = "128.0.0.0/1"
  next_hop_ip = local.vpn_server_ip
  priority    = 100
  tags        = ["server"]
}


## vpn server

resource "google_compute_instance" "vpn_server" {
  name         = "vpn-server"
  machine_type = var.instance_type
  zone         = var.server_site.zone
  
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.server_subnet_0.self_link
    
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
}


## nfs server

locals {
  nfs_server_disk_name = "shows"
  nfs_server_disk_id = "google-${local.nfs_server_disk_name}"
}

resource "google_compute_instance" "nfs_server" {
  name         = "nfs-server"
  machine_type = var.instance_type
  zone         = var.server_site.zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  
  attached_disk {
    source      = google_compute_disk.nfs_server_shows.self_link
    device_name = local.nfs_server_disk_name
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.server_subnet_0.self_link
  }

  metadata = {
    ssh-keys = "${var.gcp_username}:${tls_private_key.ssh_key.public_key_openssh}"
  }
  
  tags = ["server"]
}


resource "google_compute_disk" "nfs_server_shows" {
  name  = "nfs-server-shows"
  zone  = var.server_site.zone
  type  = "pd-standard"
  size  = 20
  physical_block_size_bytes = 4096
}


