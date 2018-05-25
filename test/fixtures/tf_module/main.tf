terraform {
  required_version = ">= 0.10.2, < 0.12"
}

provider "google" {
  credentials = "${file("${var.google_application_credentials}")}"
  project     = "${var.gcloud_project}"
  region      = "${var.gcloud_region}"
  version     = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

data "terraform_remote_state" "db" {
  backend = "local"

  config {
    path = "terraform.tfstate.d/kitchen-terraform-gcloud-db-terraform/terraform.tfstate"
  }
}

module "app" {
  source = "../../.."

  network_name   = "test-org"
  db_internal_ip = "${data.terraform_remote_state.db.internal_ip}"

  engineer_cidrs          = "${var.engineer_cidrs}"
  ssh_public_key_filepath = "${path.module}/files/insecure.pub"
}
