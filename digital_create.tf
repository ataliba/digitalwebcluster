variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}



# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_droplet" "web01" {
    image  = "ubuntu-18-04-x64"
    name   = "tf-web01"
    ipv6   = true
    region = "nyc1"
    size   = "512mb"
    user_data = "${file("config/webuserdata.sh")}"
    ssh_keys = [
     "${var.ssh_fingerprint}"
    ]
    connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
    }
}

resource "digitalocean_droplet" "web02" {
    image  = "ubuntu-18-04-x64"
    name   = "tf-web02"
    ipv6   = true
    region = "nyc1"
    size   = "512mb"
    user_data = "${file("config/webuserdata.sh")}"
    ssh_keys = [
     "${var.ssh_fingerprint}"
    ]
    connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
    }

}

resource "digitalocean_loadbalancer" "public" {
  name = "web-loader-1"
  region = "nyc1"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.web01.id}","${digitalocean_droplet.web02.id}"  ]
}
