data "google_compute_subnetwork" "app" {
  name = "${var.subnetwork_name}"
}

data "template_file" "startup_script" {
  template = "${file("${path.module}/templates/install.sh")}"

  vars {
    db_internal_ip = "${var.db_internal_ip}"
  }
}

resource "random_pet" "name" {
  length = "1"
  prefix = "app"
}

resource "google_compute_instance" "app" {
  name         = "${random_pet.name.id}"
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
  scratch_disk {}

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.app.self_link}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    sshKeys                = "ubuntu:${file(var.ssh_public_key_filepath)}"
    block-project-ssh-keys = "TRUE"
    startup-script         = "${data.template_file.startup_script.rendered}"
  }
}

resource "google_compute_firewall" "allow_ssh_ingress" {
  name    = "${random_pet.name.id}-allow-ssh-ingress"
  network = "${data.google_compute_subnetwork.app.network}"

  direction = "INGRESS"

  priority = 999

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.engineer_cidrs}"

  target_tags = ["app"]
}

resource "google_compute_firewall" "allow_http_ingress" {
  name    = "${random_pet.name.id}-allow-http-ingress"
  network = "${data.google_compute_subnetwork.app.network}"

  direction = "INGRESS"

  priority = 998

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = "${var.engineer_cidrs}"

  target_tags = ["app"]
}

resource "google_compute_firewall" "allow_data_ingress_to_db" {
  name    = "${random_pet.name.id}-allow-data-ingress-to-db"
  network = "${data.google_compute_subnetwork.app.network}"

  direction = "INGRESS"

  priority = 997

  allow {
    protocol = "tcp"
    ports    = ["28015"]
  }

  source_tags = ["app"]

  target_tags = ["db"]
}
