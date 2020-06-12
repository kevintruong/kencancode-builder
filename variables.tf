variable "region" {
  default = "asia-east1"
}

variable "zone" {
  default = "asia-east1-b"
}


variable "machine-type" {
  default = "n1-highcpu-16"
}

variable meta_startup_script {
  default = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync"
}

