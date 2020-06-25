// Configure the Google Cloud provider
//terraform {
//  backend "gcs" {
//    bucket = "kencancode"
//    prefix = "gws-builder"
//    credentials = "kencancode-builder.json"
//  }
//}

locals {
  service_name = "${var.project}-${var.prefix}"
}

provider "google" {
  credentials = file("kencancode-builder.json")
  project = var.project
  region = var.region
}


resource "google_compute_network" "default" {
  name = local.service_name
}

resource "google_compute_firewall" "default" {
  name = "${local.service_name}-firewall"
  network = google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "80",
      "8080",
      "1000-2000",
      "22"]
  }
  source_ranges = [
    "0.0.0.0/0"]

  source_tags = [
    "jenkins"]
}


//resource "google_compute_disk" "builder-data" {
//  name = "${local.service_name}-data"
//  zone = var.zone
//  size = var.disk_size
//  type = "pd-ssd"
//}

// A single Google Cloud Engine instance

resource "google_compute_instance" "kencancode" {
  name = local.service_name
  machine_type = var.machine-type
  zone = var.zone
  allow_stopping_for_update = true
  desired_status = var.vm-state
  tags = [
    "jenkins"]

  boot_disk {
    initialize_params {
      image = var.image
      size = var.disk_size
      type = "pd-ssd"
    }
  }

//  attached_disk {
//    source = google_compute_disk.builder-data.self_link
//    size = var.disk_size
//    type = "pd-ssd"
//  }

  scheduling {
    preemptible = true
    automatic_restart = false
  }


  metadata_startup_script = var.meta_startup_script

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh-user}:${file("/home/kevin/.ssh/id_rsa.pub")}"
  }

}

output "ip" {
  value = google_compute_instance.kencancode.network_interface.0.access_config.0.nat_ip
}
