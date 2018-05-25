module "db" {
  source = "git::ssh://git@github.com/newcontext/tf_module_gcloud_db.git"

  network_name = "test-org"

  engineer_cidrs          = "${var.engineer_cidrs}"
  ssh_public_key_filepath = "${path.module}/../tf_module/files/insecure.pub"
}
