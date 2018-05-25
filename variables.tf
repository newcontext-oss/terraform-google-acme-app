variable "db_internal_ip" {
  description = "Internal IP of the database server"
  type        = "string"
}

variable "engineer_cidrs" {
  description = "CIDR blocks to allow into the servers"
  type        = "list"
}

variable "ssh_public_key_filepath" {
  description = "file path to ssh public key"
  type        = "string"
}

variable "subnetwork_name" {
  description = "The name of the subnetwork in which resources will be created."
  type        = "string"
}
