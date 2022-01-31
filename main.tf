provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
  zone      = "${var.yandex_zone}"
}
module "vpc" {
  source  = "hamnsk/vpc/yandex"
  version = "0.5.0"
  description = "managed by terraform"
  yc_folder_id = "${var.yandex_folder_id}"
  name = "yc_vpc"
  subnets = local.vpc_subnets.yc_sub
}
locals {
  vpc_subnets = {
    yc_sub = [
      {
        "v4_cidr_blocks": [
          "10.128.0.0/24"
        ],
        "zone": var.yandex_zone
      }
    ]
  }
}
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = "${var.iso_id}"
    }
  }
  network_interface {
    subnet_id = module.vpc.subnet_ids[0]
    nat       = true
  }
  metadata = {
    ssh-keys = "rkhozyainov:${file("~/.ssh/id_rsa.pub")}"
  }
}