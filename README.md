# tf_module_glcoud_app

Terraform module for building out app server on Google Cloud Services

It builds compute instance(s) to run application services

## Use

Call it as a module from another Terraform repository.

```sh
module "app" {
  source = "tf_module_gcloud_app"_

  db_internal_ip = "x.x.x.x"

  network_name   = "test-org"
  engineer_cidrs = "${var.engineer_cidrs}"

  ssh_public_key_filepath = "ubuntu.pub"
}
```

## Testing

To build, validate and then destroy run these commands below:

```sh
bundle exec kitchen converge
bundle exec kitchen verify
bundle exec kitchen destroy app
bundle exec kitchen destroy db
bundle exec kitchen destroy network
```

### Prerequisites

- Ruby 2.2 or greater
- Terraform >= 0.10.2, < 0.12
- gcloud command line utility (https://cloud.google.com/sdk/)
- Google Cloud Project with a service account
- Download service account credentials to: `credentials.json`
- Create the module files directory: `mkdir test/fixtures/tf_module/files`
- Create the SSH key: `ssh-keygen -f test/fixtures/tf_module/files/insecure`
- Create a local Kitchen configuration file: `kitchen.local.yml`, add this content:

```sh
driver:
  variables:
    gcloud_project: <project-id>
```
