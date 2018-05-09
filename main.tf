provider "google" {
  version = "~> 1.0"
}

data "google_compute_network" "main" {
  name = "${var.network_name}"
}

data "google_compute_subnetwork" "app" {
  name   = "app"
}

data "template_file" "startup_script" {
  template = "${file("${path.module}/templates/install.sh")}"

  vars {
    db_internal_ip = "${var.db_internal_ip}"
  }
}

resource "google_compute_instance" "app" {
  name         = "app"
  machine_type = "n1-standard-1"
  zone         = "us-west1-a"

  allow_stopping_for_update = true

  labels = {
    name = "app"
  }

  tags = ["app"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.app.self_link}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    sshKeys = "ubuntu:${file(var.ssh_public_key_filepath)}",
    block-project-ssh-keys = "TRUE",
    startup-script = "${data.template_file.startup_script.rendered}"
  }
}

resource "google_compute_firewall" "app_tcp22_ingress" {
  name    = "app-tcp22-ingress"
  network = "${data.google_compute_network.main.name}"

  direction = "INGRESS"

  priority = 999

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.engineer_cidrs}"

  target_tags = ["app"]
}

resource "google_compute_firewall" "app_tcp80_ingress" {
  name    = "app-tcp80-ingress"
  network = "${data.google_compute_network.main.name}"

  direction = "INGRESS"

  priority = 998

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = "${var.engineer_cidrs}"

  target_tags = ["app"]
}

resource "google_compute_firewall" "app_to_db_tcp28015_ingress" {
  name    = "app-to-db-tcp28015-ingress"
  network = "${data.google_compute_network.main.name}"

  direction = "INGRESS"

  priority = 997

  allow {
    protocol = "tcp"
    ports    = ["28015"]
  }

  source_tags = ["app"]

  target_tags = ["db"]
}
