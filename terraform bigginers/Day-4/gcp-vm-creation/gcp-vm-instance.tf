provider "google" {
  credentials = file("./credentials.json")
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "firewall" {
  name    = "sample-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = [var.tag]
}

resource "google_compute_instance" "sample" {
  name = "sample"
  machine_type = var.size

  tags = [var.tag]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.user}:${file(var.pubkey)}"
  }

  provisioner "file" {
    source = "test.sh"
    destination = "/tmp/test.sh"
    connection {
      type = "ssh"
      user = "atgenautomation"
      host = google_compute_instance.sample.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod  x /tmp/test.sh",
      "/tmp/test.sh",
    ]
    connection {
      type = "ssh"
      user = "atgenautomation"
      host = google_compute_instance.sample.network_interface.0.access_config.0.nat_ip
      private_key = file("~/.ssh/id_rsa")
    }
  }
}