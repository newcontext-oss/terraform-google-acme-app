variable "db_internal_ip" {
  description = "Internal IP of the database server"
  type        = "string"
}

variable "engineer_cidrs" {
  description = "CIDR blocks to allow into the servers"
  type        = "list"
}

variable "network_name" {
  description = "Name of the network to deploy to"
  type        = "string"
}

variable "ssh_public_key_filepath" {
  description = "file path to ssh public key"
  type        = "string"
}
