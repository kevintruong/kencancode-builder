// Configure the Google Cloud provider

provider "google" {
  credentials = file("kencancode-builder.json")
  project = var.project
  region = var.region
}

resource "google_compute_network" "default" {
  name = "ken-network"
}

resource "google_compute_firewall" "default" {
  name = "kencancode-firewalls"
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


// A single Google Cloud Engine instance

resource "google_compute_instance" "kencancode" {
  name = var.instance-name
  machine_type = var.machine-type
  zone = var.zone
  allow_stopping_for_update = true
  desired_status = var.vm-state
  tags = [
    "jenkins"]
  //  desired_status = "RUNNING"

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  scheduling {
    preemptible = true
    automatic_restart = false
  }


  metadata_startup_script = var.meta_startup_script

  network_interface {
    network = google_compute_network.default.name

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh-user}:${file("~/.ssh/id_rsa.pub")}"
  }

}

output "ip" {
  value = google_compute_instance.kencancode.network_interface.0.access_config.0.nat_ip
}
