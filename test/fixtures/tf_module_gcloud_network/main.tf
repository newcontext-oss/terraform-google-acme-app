module "network" {
  source = "git::ssh://git@github.com/newcontext/tf_module_gcloud_network.git"

  organization_name = "test-org"
}
