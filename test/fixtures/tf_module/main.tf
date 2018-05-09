data "terraform_remote_state" "db" {
  backend = "local"
  config {
    path = "terraform.tfstate.d/kitchen-terraform-gcloud-db-terraform/terraform.tfstate"
  }
}

module "app" {
  source = "../../.."

  network_name = "test-org"
  db_internal_ip = "${data.terraform_remote_state.db.internal_ip}"

  engineer_cidrs = "${var.engineer_cidrs}"
  ssh_public_key_filepath = "test/fixtures/tf_module/keys/insecure.pub"
}
