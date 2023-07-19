## convenience variables

locals {
  prometheus_ip = google_compute_instance.prometheus.network_interface.0.network_ip 
}


## prometheus/grafana server

resource "google_compute_instance" "prometheus" {
  name         = "prometheus"
  machine_type = "e2-medium"
  zone         = var.client_site.zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
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

