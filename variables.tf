variable "prefix" {
  default = "gws"
}

variable "instance-name" {
  default = "kzefram"
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

variable "disk_size" {
  default = "100"
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
  default = "kevin"
}

variable vm-state {
  default = "RUNNING"
}


