variable "instance-name" {
  default = "kencancode-builder"
}
variable "project" {
  default = "kencancode-builder"
}

variable "region" {
  default = "asia-east1"
}

variable "zone" {
  default = "asia-east1-b"
}


variable "machine-type" {
  default = "n1-highcpu-2"
}

variable "image" {
  default = "debian-cloud/debian-9"
}

variable meta_startup_script {
  default = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync"
}

variable ssh-user {
  default = "ken"
}

variable vm-state {
  default = "RUNNING"
}


