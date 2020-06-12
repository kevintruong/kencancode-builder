// Configure the Google Cloud provider
provider "google" {
  credentials = file("kencancode-builder.json")
  project = "kencancode-builder"
  region = var.region
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
  name = "kencancode-builder-${random_id.instance_id.hex}"
  machine_type = var.machine-type
  zone = var.zone
  allow_stopping_for_update = true
  desired_status = var.vm-state
//  desired_status = "RUNNING"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  scheduling {
    preemptible = true
    automatic_restart = false
  }


//  metadata_startup_script = var.meta_startup_script

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh-user}:${file("~/.ssh/id_rsa.pub")}"
  }

}

output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
